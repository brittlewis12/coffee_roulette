defmodule CoffeeRoulette.Round do
  alias CoffeeRoulette.{Group, Round}

  @enforce_keys ~w(month)a
  defstruct month: nil,
    state: :initialized,
    participants: MapSet.new,
    groups: nil

  @states ~w(
    initialized
    unsorted
    sorted
  )a

  def new(month), do: %Round{month: month}

  # TODO: incorporate data loader? simplify some of its shit? or maybe just make `%RoundsSheet{}` already?
  # def load(:from_sheet, month, participants, sheet)
  # def load(:from_raw, month, participants, sheet)
  def load({groups, month}) do
    participants = groups |> all_participants_for_groups
    %Round{month: month, participants: participants, groups: groups, state: :sorted}
  end

  def set_participants(%Round{state: :initialized} = round, participants) do
    new_participants = Enum.into(participants, round.participants)
    {:ok, %Round{round|participants: new_participants, state: :unsorted}}
  end
  def set_participants(%Round{} = _round, _p), do: {:error, :participants_already_set}

  def sort(%Round{state: :unsorted} = round, history), do: do_sort(round, history)
  def sort(%Round{state: :initialized} = _round, _history), do: {:error, :participants_not_set}
  def sort(%Round{state: :sorted} = _round, _history), do: {:error, :already_sorted}

  @minimum_group_size 3
  defp do_sort(%Round{} = round, history) do
    with participants <- round.participants,
         _num_groups <- participants |> Enum.count |> div(@minimum_group_size),
         groups <- []
    do
      groups =
        participants
        |> Enum.map(fn participant ->
          {participant, compatible_participants(participant, participants, history)}
        end)
        |> Enum.sort_by(fn {_p, compatible} -> Enum.count(compatible) end, &>=/2)
        |> Enum.reduce(groups, &build_group_for_participant/2)
      {:ok, %Round{round|groups: groups, state: :sorted}}
    end
  end

  # TODO: Not handling any cases where not clean multiple of 3
  defp build_group_for_participant({participant, compatible}, groups) do
    already_placed = groups |> Enum.flat_map(& &1.participants)
    if (Enum.member?(already_placed, participant)) do
      groups
    else
      available = (compatible -- already_placed)
      partners = available |> Enum.take(@minimum_group_size - 1)
      group = Group.new(:stuff, [participant|partners])
      [group|groups]
    end
  end

  defp compatible_participants(participant, participants, history) do
    past_group_members =
      participant
      |> past_groups(history)
      |> all_participants_for_groups

    participants
    |> MapSet.difference(past_group_members)
    |> Enum.reject(fn potential_group_member ->
      potential_group_member.guild == participant.guild
    end)
    |> Enum.sort_by(fn potential_group_member ->
      potential_group_member.preferred_time_of_day == participant.preferred_time_of_day
    end, &>=/2)
  end

  defp past_groups(participant, history) do
    history
    |> Enum.flat_map(& &1.groups)
    |> Enum.filter(
      fn group ->
        MapSet.member?(group.participants, participant)
      end)
  end

  defp all_participants_for_groups(groups) do
    groups
    |> Enum.reject(& &1.id == :none) # 🤔...
    |> Enum.flat_map(& &1.participants)
    |> Enum.into(MapSet.new)
  end
end
