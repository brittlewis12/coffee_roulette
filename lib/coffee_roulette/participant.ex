defmodule CoffeeRoulette.Participant do
  alias __MODULE__

  @enforce_keys [:email, :guild]
  defstruct [:email, :guild, :preferred_time_of_day]

  # TODO: use Saul to validate data structures for real
  # TODO: this should probably not require code changes to update
  #       & probably should be able to be changed at runtime
  @valid_guilds ~w(
    cx
    marketing
    legal
    engineering
    production
    data_science
    creative
    people
    operations
    product
    it
    finance
    culinary
    ceo
    unknown
  )a

  def new(email, guild \\ :unknown, preferred_time_of_day \\ nil)
  def new(email, guild, preferred_time_of_day) when guild in(@valid_guilds) do
    {:ok, %Participant{email: email, guild: guild, preferred_time_of_day: preferred_time_of_day}}
  end
  def new(_, guild, _), do: {:error, {:invalid_guild, guild}}
end
