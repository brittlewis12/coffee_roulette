defmodule CoffeeRoulette.Participant do
  alias __MODULE__

  @enforce_keys [:email, :guild]
  defstruct [:email, :guild, :preferred_time_of_day]

  # TODO: this should probably not require code changes to update
  #       & probably should be able to be changed at runtime
  # TODO: use Saul to validate data structures for real
  @valid_guilds [:engineering, :people, :product, :operations, :marketing]

  # def new(email, guild, preferred_time_of_day \\ nil) when guild in(@valid_guilds) do
  def new(email, guild, preferred_time_of_day \\ nil) do
    {:ok, %Participant{email: email, guild: guild, preferred_time_of_day: preferred_time_of_day}}
  end
  # def new(_, _, _), do: {:error, :invalid_guild}
end
