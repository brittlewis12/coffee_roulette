defmodule CoffeeRoulette.Group do
  alias CoffeeRoulette.{Participant, Group}

  @enforce_keys [:participants, :id]
  defstruct [:participants, :id]

  def new(id, participants \\ []) when is_list(participants) do
    %Group{id: id, participants: MapSet.new(participants)}
  end

  def add(%Group{} = group, %Participant{} = participant), do:
    update_in group.participants, &MapSet.put(&1, participant)

  def union(%Group{} = group1, %Group{} = group2), do:
    update_in group1.participants, &MapSet.union(&1, group2.participants)
end
