Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ActionTypes = require('scripts/constants/constants').ActionTypes
API = require 'scripts/utils/api'
module.exports =

  changeScore: (info) ->
    API.changeScore(info)
    Dispatcher.handleRequestAction(
      type: ActionTypes.CHANGE_SCORE
      data: info
    )

  getPlayers: () ->
    API.getPlayers()

  getTeams: () ->
    API.getTeams()

  getRecentMatches: () ->
    API.getRecentMatches()

  startMatch: (players) ->
    API.startMatch(players)

  registerPlayerNFC: (nfc, player) ->
    API.registerPlayerNFC(nfc, player)

  endMatch: (code) ->
    API.endMatch(code)

  submitEmail: (email) ->
    API.registerEmailNotification(email)

  submitSMS: (email) ->
    API.registerSMSNotification(email)
