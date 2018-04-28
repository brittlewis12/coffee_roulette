defmodule CoffeeRoulette.Group do
  alias CoffeeRoulette.{Participant, Group}

  @enforce_keys [:participants]
  defstruct [:participants]

  def new(participants \\ [])
  def new(participants) when is_list(participants) do
    {:ok, %Group{participants: MapSet.new(participants)}}
  end
  def new(_), do: {:error, :invalid_participants}
end
