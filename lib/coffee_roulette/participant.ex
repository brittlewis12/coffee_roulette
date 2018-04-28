defmodule CoffeeRoulette.Participant do
  alias __MODULE__

  @enforce_keys [:name, :guild]
  defstruct [:name, :guild, :preferred_time_of_day]

  # TODO: this should probably not require code changes to update
  #       & probably should be able to be changed at runtime
  # TODO: use Saul to validate data structures for real
  @valid_guilds [:engineering, :people, :product, :operations, :marketing]

  def new(name, guild, preferred_time_of_day \\ nil)
  def new(name, guild, preferred_time_of_day) when guild in(@valid_guilds) do
    {:ok, %Participant{name: name, guild: guild, preferred_time_of_day: preferred_time_of_day}}
  end
  def new(_, _, _), do: {:error, :invalid_guild}
end
