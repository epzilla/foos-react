Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ActionTypes = require('scripts/constants/constants').ActionTypes
Announcer = require 'scripts/utils/announcer'

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
    sound = document.querySelector 'audio'
    sound.src = data.sound
    if data.status isnt 'new'
      sound.play()
      match = data.updatedMatch
      thisGame = match.scores[match.gameNum - 1]
      totalPoints = thisGame.team1 + thisGame.team2
      if totalPoints % 5 is 0 and totalPoints isnt 0
        sound.addEventListener 'ended', listener = () ->
          Announcer.announceSwitch()
          sound.removeEventListener 'ended', listener
    return

  receiveRecentMatches: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_RECENT_MATCHES
      data: data
    )
    return

  receiveRegisteredPlayer: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_REGISTERED_PLAYER
      data: data
    )

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

  receiveMatchError: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_MATCH_ERROR
      data: data
    )
    return

  receiveNFCError: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_NFC_ERROR
      data: data
    )
    return

  receiveNewPlayer: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_NEW_PLAYER
      data: data
    )
    return

  offlineScoreUpdate: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.OFFLINE_SCORE_UPDATE
      data: data
    )
    return

  sendAlert: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_ALERT
      data: data
    )
    if !data.persistent
      window.setTimeout(=>
        @clearAlerts()
        return
      , 5000)
      return
    return

  clearAlerts: () ->
    Dispatcher.handleServerAction(
      type: ActionTypes.CLEAR_ALERTS
    )
    return