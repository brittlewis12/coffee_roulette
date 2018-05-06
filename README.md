# CoffeeRoulette

**TODO: Add description**

## Features
* Load participants from spreadsheet data
* Load old groups from the spreadsheet data
* Fetch spreadsheet data live

## Ideas
* structs for participant, group, round/month
* participant would have email, guild, time_of_day_pref (could be built directly from raw sheet data)
  * would also need to track who is currently active -- should this be on participant?
  * should participant be pinned to spreadsheet data or mixed in and managed exclusively in app?
* group could be a MapSet of participants
* round would be MapSet of groups
* core function would take a list of active participants & all previous rounds as input and would output a new list of groups
* GenServer that pulls the spreadsheet and can be queried for the data?
* could keep all rounds groups that way for processing, but might be more useful to transform and orient around individuals — who have they already been grouped with? perhaps the same approach should be applied to guilds, orient around shared membership & filter

### sort algo ideas
* brute force
  * calculate expected number of groups by dividing total participants by desired group size
  * any leftovers indicate the number of groups that would require an extra
  * loop to build desired # of groups randomly and validate against invariants; repeat until all checks satisfied
  * probably would be slow over time, perhaps sooner than I expect
  * at same time, leaning on randomness at key points is a staple of CS
* provide heuristic groupings up front?
* grouping is process of evaluating a pool of available participants starting with the full group and decreasing as groups are established
  * perhaps should sort by people with the _most_ exclusions up front, as they'll be the hardest to group the longer they're not sorted
    * this means large guilds first, then long time participants — could build up a ranked list of exclusions, perhaps phased ranks rather than discrete
  * recursion :)
* this problem is not dissimilar to recipe suggester/taggregator
  * collect history for user, create intermediary representation for speed & efficiency, use to inform on-the-fly calculation
* potential opportunities for parallelism in pipelining?
    * exercise in learning optimization/introspection tools in elixir

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/coffee_roulette](https://hexdocs.pm/coffee_roulette).

