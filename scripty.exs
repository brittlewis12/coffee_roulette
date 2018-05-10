alias CoffeeRoulette.SortingHat
{:ok, pid} = SortingHat.start_link("May")
# hat1 = :sys.get_state pid
SortingHat.set_participants(
  pid,
  hat.history |> Enum.at(-1) |> Map.fetch!(:participants)
)
# hat2 = :sys.get_state pid
{:ok, round} = SortingHat.sort(pid)

round.groups |> Enum.map(& &1.participants) |> Enum.map(fn parts -> Enum.map(parts, & &1.email) end)
