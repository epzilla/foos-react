# API

## List all players
`GET` `/api/players`

## Get a specific player by ID
`GET` `/api/players/:playerId`

## List all matches
`GET` `/api/matches`

## List recent matchers
`GET` `/api/matches/recent`

## Get current match
`GET` `/api/matches/current`

## Get a specific match by ID
`GET` `/api/matches/:matchId`

## Create new player
`POST` `/api/players`

### schema (application/json):
`{"name":"Bobby Player"}`


## SNAP Node -> Gateway RPC
- `increment(snap_address)`
  - the only RPC we should need on the snappy side is "Hey, increment my score!" and if you send the address with it, the gateway should be able to figure out which team that corresponds to.

## Gateway -> Web Server (Socket)
- `increment` : `{team:(team1|team2)}`
  - We could do this one with either REST or sockets, whichever we think would be better. A REST route might be something like: `/api/increment/:team`

## Web Server -> Gateway (Socket)
- `newMatch`
  - Probably doesn't matter what the message contents are here. Just knowing we received "newMatch" should tell the gateway to reset which nodes correspond to heads/tails
- `nextGame`
