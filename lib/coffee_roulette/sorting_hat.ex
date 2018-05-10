defmodule CoffeeRoulette.SortingHat do
  alias CoffeeRoulette.{DataLoader, Round}

  use GenServer

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name) # Registry???
  end

  def set_participants(sorting_hat, participants) do
    GenServer.call(sorting_hat, {:set_participants, participants})
  end

  def sort(sorting_hat) do
    GenServer.call(sorting_hat, :sort)
  end

  def init(name) do
    with round <- Round.new(name),
         {:ok, history} <- fetch_history()
    do
      {:ok, %{round: round, history: history}}
    else
      {:error, _reason} = e -> e
      :error -> :error
      _ -> :error
    end
  end

  def handle_call({:set_participants, participants}, _from, state) do
    case Round.set_participants(state.round, participants) do
      {:ok, round} -> {:reply, :ok, %{state|round: round}}
      {:error, _msg} = e -> {:reply, e, state}
      :error -> {:reply, :error, state}
    end
  end

  def handle_call(:sort, _from, state) do
    case Round.sort(state.round, state.history) do
      {:ok, round} = reply -> {:reply, reply, %{state|round: round}}
      _ -> {:reply, :error, state}
    end
  end

  @json_response_file "/Users/britt/Downloads/gsheets-values-coffee-roulette-response.json"

  # TODO: convert to live request
  defp fetch_history do
    with {:ok, raw_response_body} <- File.read @json_response_file do
      raw_response_body
      |> DataLoader.extract_overkill
      |> Map.fetch(:historical_rounds)
    else
      {:error, _reason} = e -> e
      :error -> :error
      _ -> :error
    end
  end
end
