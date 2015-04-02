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
