Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ActionTypes = require('scripts/constants/constants').ActionTypes
API = require 'scripts/utils/api'
module.exports =

  changeScore: (info) ->
    API.changeScore(info).then (res) ->
      Dispatcher.handleRequestAction(
        type: ActionTypes.CHANGE_SCORE
        data: res
      )
    return
