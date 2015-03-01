Rest = require './rest-service'
ServerActionCreator = require 'scripts/actions/server-action-creator'

module.exports = 

  getCurrentMatch: ->
    Rest.get '/api/matches/current'
      .then (res) ->
        ServerActionCreator.receiveCurrentMatch res

  getRecentMatches: ->
    Rest.get '/api/matches/recent'
      .then (res) ->
        ServerActionCreator.receiveRecentMatches res

  getHomeData: ->
    Promise.all [Rest.get('/api/matches/current'), Rest.get('/api/matches/recent')]
      .then (res) ->
        currentMatch = if res[0].length > 0 then res[0] else null
        recentMatches = if res[1].length > 0 then res[1] else []
        ServerActionCreator.receiveHomeData(
          currentMatch: currentMatch
          recentMatches: recentMatches
        )
      .catch (err) ->
        console.error err.stack