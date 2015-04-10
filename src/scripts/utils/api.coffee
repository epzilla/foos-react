Rest = require './rest-service'
ServerActionCreator = require 'scripts/actions/server-action-creator'
socket = require 'scripts/utils/socket'
ls = require 'scripts/utils/local-storage'

module.exports =

  getCurrentMatch: ->
    Rest.get '/api/matches/current'
      .then (res) ->
        ServerActionCreator.receiveCurrentMatch res

  getSeriesHistory: (team1, team2) ->
    Rest.get('/api/matches/series/?team1=' + team1 + '&team2=' + team2)
      .then (res) ->
        ServerActionCreator.receiveSeriesHistory res

  getRecentMatches: ->
    Rest.get '/api/matches/recent'
      .then (res) ->
        ServerActionCreator.receiveRecentMatches res

  getPlayers: ->
    players = ls.get 'players'
    if players
      ServerActionCreator.receivePlayers players

    Rest.get '/api/players'
      .then (res) ->
        if not players or players.length is 0 or JSON.stringify(players) isnt JSON.stringify(res)
          ls.set 'players', res
          ServerActionCreator.receivePlayers res

  getTeams: ->
    teams = ls.get 'teams'
    if teams
      ServerActionCreator.receiveTeams teams

    Rest.get '/api/teams'
      .then (res) ->
        if not teams or teams.length is 0 or JSON.stringify(teams) isnt JSON.stringify(res)
          ls.set 'teams', res
          ServerActionCreator.receiveTeams res

  getHomeData: ->
    self = this
    Promise.all [Rest.get('/api/matches/current'), Rest.get('/api/matches/recent'), Rest.get('/api/matches/playersInPool')]
      .then (res) ->
        currentMatch = if res[0].length > 0 then res[0][0] else null
        recentMatches = if res[1].length > 0 then res[1] else []
        playersInPool = if res[2].length > 0 then res[2] else []
        ServerActionCreator.receiveHomeData(
          currentMatch: currentMatch
          recentMatches: recentMatches
          playersInPool: playersInPool
        )
        if currentMatch
          self.getSeriesHistory currentMatch.team1._id, currentMatch.team2._id
      .catch (err) ->
        console.error err.stack

  changeScore: (info) ->
    if socket.connected
      socket.emit 'scoreChange', info
    else
      ServerActionCreator.offlineScoreUpdate info

  startMatch: (players) ->
    self = this
    Rest.post('/api/matches', players)
      .then (res) ->
        ls.set 'matchID', res._id
        self.getHomeData()
    return

  registerPlayerNFC: (nfc, player) ->
    Rest.put('/api/players/' + player, {nfc: nfc})
      .then (res) ->
        socket.emit 'playerNFC', {nfc: res.nfc}