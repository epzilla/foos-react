Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
ViewActionCreator = require 'scripts/actions/view-action-creator'
Announcer = require 'scripts/utils/announcer'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'

_recentMatches = []
_currentMatch = {}
_seriesHistory = {}
_soundToPlay = ''
_winner = undefined
_prediction = undefined

_updateOfflineScore = (info) ->
  if info.plusMinus is 'plus'
    _currentMatch.scores[_currentMatch.gameNum - 1][info.team]++
    if _currentMatch.scores[_currentMatch.gameNum - 1][info.team] is 10
      if _currentMatch.gameNum isnt 3
        _currentMatch.gameNum++
        _currentMatch.scores.push(
          team1: 0,
          team2: 0
        )
  else
    if _currentMatch.scores[_currentMatch.gameNum - 1][info.team] isnt 0
      _currentMatch.scores[_currentMatch.gameNum - 1][info.team]--

MatchStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback

  getRecentMatches: ->
    _recentMatches

  getCurrentMatch: ->
    _currentMatch

  getSeriesHistory: ->
    _seriesHistory

  getSound: ->
    _soundToPlay

  getWinner: ->
    _winner
)

MatchStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_HOME_DATA
      _currentMatch = action.data.currentMatch or {}
      _recentMatches = if action.data.recentMatches.length > 0 then action.data.recentMatches else []
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_CURRENT_MATCH
        _currentMatch = action.data
        MatchStore.emitChange()
    when ActionTypes.RECEIVE_SERIES_HISTORY
      _seriesHistory = action.data
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_RECENT_MATCHES
      _recentMatches = action.data
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_PREDICTION
      _prediction = action.data.prediction
      MatchStore.emitChange()
    when ActionTypes.RECEIVE_SCORE_UPDATE
      if action.data.status is 'new'
        _currentMatch = action.data.updatedMatch
        _winner = undefined
        ViewActionCreator.getSeriesHistory(_currentMatch.team1._id, _currentMatch.team2._id)
        Announcer.giveNewMatchInstructions(_currentMatch, action.data.sound)
        MatchStore.emitChange()
      else if action.data.status is 'aborted'
        _currentMatch = {}
        MatchStore.emitChange()
      else
        _currentMatch.scores = action.data.updatedMatch.scores
        _currentMatch.gameNum = action.data.updatedMatch.gameNum
        _currentMatch.gameStartTime = action.data.updatedMatch.gameStartTime
        _currentMatch.active = action.data.updatedMatch.active
        _soundToPlay = action.data.sound
        if action.data.status is 'finished'
          _currentMatch.active = true
          _winner = action.data.winner
          sound = document.querySelector 'audio'
          sound.addEventListener 'ended', () ->
            _currentMatch.active = false
            _winner = undefined
            MatchStore.emitChange()
          ViewActionCreator.getRecentMatches()
        MatchStore.emitChange()
    when ActionTypes.OFFLINE_SCORE_UPDATE
      _updateOfflineScore action.data
      MatchStore.emitChange()
)

module.exports = MatchStore