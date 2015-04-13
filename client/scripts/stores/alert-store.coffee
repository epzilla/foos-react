Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
_ = require 'lodash'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_alerts = []

AlertStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT
    return

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback
    return

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback
    return

  getAlerts: ->
    _alerts
)

AlertStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_ALERT
      _alerts[0] = action.data
    when ActionTypes.CLEAR_ALERTS
      _alerts.pop()
  AlertStore.emitChange()
  return
)

module.exports = AlertStore