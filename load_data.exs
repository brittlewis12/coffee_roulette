alias CoffeeRoulette.{DataLoader, Round, Group, Participant}

# returns a map with native data structures representing the parsed and
# lightly transformed sheets data as well as app data structures representing
# more useful representations of past coffee roulette rounds: participants and
# their past groups:
#     (...)
#     iex(2)> Map.keys stuff
#     [:historical_rounds, :participants, :raw_form_values,
#     :raw_morning_afternoon_values]
{:ok, raw_response_body} =
  File.read "/Users/britt/Downloads/gsheets-values-coffee-roulette-response.json"
stuff = DataLoader.extract_overkill raw_response_body
