Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'

ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_teams = []
_teamMatches = []

TeamStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback

  getTeams: ->
    _teams

  getTeamInfo: (id) ->
    _.find(_teams, {_id: id})

  getTeamMatches: (id) ->
    _teamMatches
)

TeamStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_TEAMS
      _teams = action.data
    when ActionTypes.RECEIVE_TEAM_MATCHES
      _teamMatches = action.data
  TeamStore.emitChange()
)

module.exports = TeamStore