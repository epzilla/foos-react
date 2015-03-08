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
    return

  getPlayers: () ->
    API.getPlayers()
    return

  startMatch: (players) ->
    API.startMatch(players)
    return
