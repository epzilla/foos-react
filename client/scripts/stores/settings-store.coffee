Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
_ = require 'lodash'
ls = require 'scripts/utils/local-storage'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_muted = ls.get('muted') or false

SettingsStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback

  isMuted: ->
    _muted
)

SettingsStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.MUTE
      _muted = true
      ls.set('muted', true)
    when ActionTypes.UNMUTE
      _muted = false
      ls.set('muted', false)
  SettingsStore.emitChange()
)

module.exports = SettingsStore