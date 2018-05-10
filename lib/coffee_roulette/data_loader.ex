defmodule CoffeeRoulette.DataLoader do
  alias CoffeeRoulette.{Group, Participant, Round}

  def extract_overkill(json_data) do
    # TODO: is this order guaranteed between requests? Should I be fetching each individually?
    [form_responses_values|morning_and_afternoon_rounds_values] =
      extract_coffee_roulette_data(json_data)

    [morning_rounds_data, afternoon_rounds_data] =
      morning_and_afternoon_rounds_values
      |> Enum.map(&raw_rounds_data/1)

    participants =
      morning_rounds_data
      |> Enum.concat(afternoon_rounds_data)
      |> Enum.map(&participant_from_rounds_row/1)

    historical_rounds =
      [morning_rounds_data, afternoon_rounds_data]
      |> Enum.map(&rounds_groups_from_rounds_data(&1, participants))
      |> merge_rounds_groups
      |> Enum.with_index
      |> Enum.map(&Round.load/1)

    %{
      raw_form_values: form_responses_values,
      raw_morning_afternoon_values: morning_and_afternoon_rounds_values,
      participants: participants,
      historical_rounds: historical_rounds
    }
  end

  def extract_coffee_roulette_data(json_data) do
    json_data
    |> Jason.decode!
    |> Map.fetch!("valueRanges")
    |> Enum.map(&Map.fetch!(&1, "values"))
  end

  # how to get newly added people's guilds? not on form. should
  # probably be manual in my tool eventually, part of their
  # spreadsheet process in the meantime
  def raw_rounds_data(sheet) do
    sheet
    |> Enum.drop(1) # drop header row
    |> Enum.map(&Enum.take(&1, total_column_count(sheet)))
  end

  def participant_from_rounds_row([email | [guild | [tod_pref | _rest]]] = rounds_row) do
    # TODO: refactor into normalize_guild function
    guild = guild |> String.downcase |> String.replace(" ", "_") |> String.to_atom
    case Participant.new(email, guild, tod_pref) do
      {:ok, participant} -> participant
      _ -> {:error, {:failed_to_build_participant_from_row, rounds_row}}
    end
  end

  def rounds_groups_from_rounds_data(raw_rounds_data, participants) do
    raw_rounds_data
    |> filter_rounds_data_for_participants(participants)
    |> build_groups_by_round(participants)
  end

  def filter_rounds_data_for_participants(raw_rounds_data, participants) do
    existing_emails = emails_for_participants(participants)
    raw_rounds_data
    |> Enum.filter(fn [email|_rest] ->
      MapSet.member?(existing_emails, email)
    end)
  end

  def build_groups_by_round(rounds_data, participants) do
    rounds_data
    |> Enum.reduce(%{}, fn raw_participant_rounds, groups_by_round ->
      [email|[_guild|[raw_time_of_day|participant_group_numbers]]] = raw_participant_rounds
      time_of_day = normalize_tod(raw_time_of_day)
      participant = participants |> Enum.find(& &1.email == email) # TODO: Registry? may be wise to normalize, ok for now tho

      participant_group_numbers
      |> Enum.with_index
      |> Enum.reduce(groups_by_round, fn {group_number_str, index}, groups ->
        with group_id = group_id_from_str(group_number_str, time_of_day),
             group = Group.new(group_id),
             round_id = index + 1,
             round_access_fn = Access.key(round_id, %{}),
             group_access_fn = Access.key(group_id, group)
        do
          update_in(
            groups, [round_access_fn, group_access_fn], &Group.add(&1, participant)
          )
        end
      end)
    end)
  end

  def merge_rounds_groups(rounds_groups) do
    rounds_groups
    |> Enum.map(&Map.values/1)
    |> Enum.zip
    |> Enum.map(&merge_round_groups/1)
    |> Enum.map(&Map.values/1)
  end

  defp merge_round_groups({round_groups_a, round_groups_b}), do:
    Map.merge(round_groups_a, round_groups_b, fn _k, a, b -> Group.union(a, b) end)

  defp total_column_count(sheet) do
    sheet
    |> Enum.at(0)
    |> Enum.count
  end

  # NOTE: matthew.spaulding@plated.com, ryan.treacy@plated.com responded twice:
  # doesn't matter for getting emails tho! — if this data is needed, only take latest?
  def all_emails(form_responses_values) do
    form_responses_values
    |> Enum.drop(1) # drop header row
    |> Enum.map(fn [_ts|[email|_rest]] -> email end)
    |> MapSet.new
  end

  def emails_for_participants(participants) do
    participants |> MapSet.new(& &1.email)
  end

  def diff_new_emails(all_emails, existing_emails) do
    MapSet.difference(all_emails, existing_emails)
  end

  @did_not_participate ["", "?", "n/a"]
  defp group_id_from_str(str, _) when str in @did_not_participate, do: :none
  defp group_id_from_str("done", _), do: :done
  defp group_id_from_str(group_number_str, time_of_day) do
    case group_id_number(group_number_str) do
      {:ok, {:clean, group_number}} -> "#{time_of_day}:#{group_number}"
      {:ok, {:flip, group_number}} -> "#{other_tod(time_of_day)}:#{group_number}"
      :error              -> "#{time_of_day}:unknown_check_sheet"
    end
  end
  defp group_id_number(group_number_str) do
    case Integer.parse(group_number_str) do
      {group_number, ""} -> {:ok, {:clean, group_number}}
      {group_number, _} -> {:ok, {:flip, group_number}}
      :error = e        -> e
    end
  end

  defp normalize_tod(raw_tod) do
    raw_tod |> String.trim |> String.downcase |> check_tod
  end

  defp check_tod("afternoon" = tod), do: tod
  defp check_tod("morning" = tod), do: tod
  defp check_tod(invalid), do: {:error, {:invalid_time_of_day, invalid}}

  defp other_tod("morning"), do: "afternoon"
  defp other_tod("afternoon"), do: "morning"
end
