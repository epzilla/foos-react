Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ActionTypes = require('scripts/constants/constants').ActionTypes

module.exports =

  receiveHomeData: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_HOME_DATA
      data: data
    )
    return

  receiveCurrentMatch: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_CURRENT_MATCH
      data: data
    )
    return

  receiveSeriesHistory: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_SERIES_HISTORY
      data: data
    )
    return

  receiveScoreUpdate: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_SCORE_UPDATE
      data: data
    )
    return

  receiveRecentMatches: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_RECENT_MATCHES
      data: data
    )
    return

  receivePlayers: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_PLAYERS
      data: data
    )
    return

  receiveTeams: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_TEAMS
      data: data
    )
    return