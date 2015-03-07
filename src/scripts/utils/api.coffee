Rest = require './rest-service'
ServerActionCreator = require 'scripts/actions/server-action-creator'
socket = require 'scripts/utils/socket'
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

  getHomeData: ->
    self = this
    Promise.all [Rest.get('/api/matches/current'), Rest.get('/api/matches/recent')]
      .then (res) ->
        currentMatch = if res[0].length > 0 then res[0][0] else null
        recentMatches = if res[1].length > 0 then res[1] else []
        ServerActionCreator.receiveHomeData(
          currentMatch: currentMatch
          recentMatches: recentMatches
        )
        if currentMatch
          self.getSeriesHistory(currentMatch.team1._id, currentMatch.team2._id)
      .catch (err) ->
        console.error err.stack

  changeScore: (info) ->
    self = this
    socket.emit 'scoreChange', info