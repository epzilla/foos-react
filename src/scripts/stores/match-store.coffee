Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'

ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_recentMatches = []
_currentMatch = null

MatchStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT
    return
  
  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback
    return
  
  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback
    return
  
  getRecentMatches: ->
    _recentMatches

  getCurrentMatch: ->
    _currentMatch
)

MatchStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_HOME_DATA
      _currentMatch = action.data.currentMatch or null
      _recentMatches = if action.data.recentMatches.length > 0 then action.data.recentMatches else []
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_CURRENT_MATCH
      _currentMatch = action.data
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_RECENT_MATCHES
      _recentMatches = action.data
      MatchStore.emitChange()
    # do nothing
  return
)

module.exports = MatchStore