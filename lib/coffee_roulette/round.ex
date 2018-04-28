defmodule CoffeeRoulette.Round do
  alias CoffeeRoulette.{Group, Round}

  @enforce_keys [:name, :groups]
  defstruct [:name, :groups]

  def new(name, groups \\ [])
  def new(name, groups) when is_list(groups) do
    {:ok, %Round{name: name, groups: MapSet.new(groups)}}
  end
  def new(_, _), do: {:error, :invalid_groups}
end
