router = require('express').Router()
players = require './services/players'
matches = require './services/matches'
teams = require './services/teams'
sounds = require './services/sounds'
email = require './services/email'
carriers = require './services/carriers'

init = (socket) ->
  matches.init socket
  players.init()
  carriers.init()

# middleware to use for all requests
router.use (req, res, next) ->
  # do logging
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Authorization, Access-Control-Allow-Origin, Access-Control-Allow-Methods'
  res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
  res.header 'Access-Control-Allow-Origin', '*'
  next()

# Players
router.post '/players', players.create
router.get '/players', players.findAll
router.get '/players/:playerId', players.find
router.put '/players/:playerId', players.update
router.put '/players/updateByName/:name', players.updateByName
# router.put '/reset/players', players.resetAll
# router.put '/reset/playerByName/:name', players.resetOneByName
# router.put '/reset/playerById/:id', players.resetOneById

# Matches
router.post '/matches', matches.create
router.post '/matches/createRandomWithPlayers', matches.createRandomWithPlayers
router.post '/matches/addPlayerToPool', matches.addPlayerToPool
router.get '/matches/playersInPool', matches.getPlayersInPool
router.get '/matches', matches.findAll
router.get '/matches/current', matches.getCurrentMatch
router.get '/matches/recent', matches.getRecentMatches
router.get '/matches/series', matches.getSeriesHistory
router.get '/matches/:matchId', matches.find
router.put '/matches/:matchId', matches.update
router.put '/matches/changeScore', matches.changeScore
router.put '/matches/end/:matchId', matches.endMatch
router.get '/matchesByPlayer/:playerID', matches.getMatchesByPlayer
router.get '/matchesByTeam/:teamID', matches.getMatchesByTeam

# Teams
router.get '/teams', teams.findAll
router.get '/teams/:teamId', teams.find

# Email Notifications
router.post '/notificationByEmailAddress', email.createNotificationByEmailAddress
router.post '/notificationByPlayerId', email.createNotificationByPlayerId
router.post '/notificationBySMS', email.createNotificationBySMS

# Carriers
router.get '/carriers', carriers.findAll

# Sounds
# router.get '/sounds/random', sounds.getRandomSound

module.exports =
  router: router
  init: init