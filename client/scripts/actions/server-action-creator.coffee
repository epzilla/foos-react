Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ActionTypes = require('scripts/constants/constants').ActionTypes
Announcer = require 'scripts/utils/announcer'
Settings = require 'scripts/stores/settings-store'
announcementQueued = false

module.exports =

  receiveHomeData: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_HOME_DATA
      data: data
    )

  receiveCurrentMatch: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_CURRENT_MATCH
      data: data
    )

  receiveSeriesHistory: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_SERIES_HISTORY
      data: data
    )

  receiveScoreUpdate: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_SCORE_UPDATE
      data: data
    )
    sound = document.querySelector 'audio'
    sound.src = data.sound
    if data.status isnt 'new'
      if not Settings.isMuted()
        sound.play()
      match = data.updatedMatch
      thisGame = match.scores[match.gameNum - 1]
      totalPoints = thisGame.team1 + thisGame.team2
      if totalPoints % 5 is 0 and totalPoints isnt 0 and data.status isnt 'finished'
        if not announcementQueued
          sound.addEventListener 'ended', listener = () ->
            Announcer.announceSwitch()
            sound.removeEventListener 'ended', listener
            announcementQueued = false
          announcementQueued = true

  receiveRecentMatches: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_RECENT_MATCHES
      data: data
    )

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

  receivePlayerNames: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_PLAYER_NAMES
      data: data
    )

  receivePrediction: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_PREDICTION
      data: data
    )
    Announcer.queuePrediction data.prediction

  receiveTeams: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_TEAMS
      data: data
    )

  receiveMatchError: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_MATCH_ERROR
      data: data
    )

  receiveNFCError: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_NFC_ERROR
      data: data
    )
    Announcer.unrecognizedTag()

  receiveNewPlayer: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_NEW_PLAYER
      data: data
    )

  receivePlayersInPool: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_PLAYERS_IN_POOL
      data: data
    )

  receivePlayerMatches: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_PLAYER_MATCHES
      data: data
    )

  receiveTeamMatches: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_TEAM_MATCHES
      data: data
    )

  receiveCarriers: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_CARRIERS
      data: data
    )

  offlineScoreUpdate: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.OFFLINE_SCORE_UPDATE
      data: data
    )

  sendAlert: (data) ->
    Dispatcher.handleServerAction(
      type: ActionTypes.RECEIVE_ALERT
      data: data
    )
    if !data.persistent
      window.setTimeout(=>
        @clearAlerts()
      , 5000)

  clearAlerts: () ->
    Dispatcher.handleServerAction(
      type: ActionTypes.CLEAR_ALERTS
    )

  heckle: (data) ->
    Announcer.heckle data