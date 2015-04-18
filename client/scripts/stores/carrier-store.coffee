Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
_ = require 'lodash'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_carriers = []

CarrierStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT
    return

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback
    return

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback
    return

  getCarriers: ->
    _carriers
)

CarrierStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_CARRIERS
      _carriers = action.data
  CarrierStore.emitChange()
  return
)

module.exports = CarrierStore