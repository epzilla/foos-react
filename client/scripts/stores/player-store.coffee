Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
Announcer = require 'scripts/utils/announcer'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'
_ = require 'lodash'

_players = []

# These are only used in new player registration at the beginning of a match
_playerNames = []
_newPlayer = undefined
_didTimeout = false
_unrecognized = undefined
_createdPlayer = undefined

# This is used in the email notification screen
_playerEmails = []

PlayerStore = assign({}, EventEmitter.prototype,
  emitChange: ->
    @emit CHANGE_EVENT
    return

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback
    return

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback
    return

  getPlayers: ->
    _players

  getNewPlayerInfo: ->
    _newPlayer

  getPlayerNames: ->
    _playerNames

  getPlayerEmails: ->
    _playerEmails

  didTimeout: ->
    _didTimeout

  getUnrecognizedNFC: ->
    _unrecognized

  getCreatedPlayer: ->
    _createdPlayer
)

PlayerStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_PLAYERS
      _players = action.data
      _playerEmails = _.uniq(_.pluck _players, 'email')
      _playerNames = _.pluck _players, 'name'
    when ActionTypes.RECEIVE_HOME_DATA
      _playerNames = action.data.playersInPool
      if _playerNames.length > 0
        _newPlayer = _playerNames[_playerNames.length - 1]
    when ActionTypes.RECEIVE_REGISTERED_PLAYER
      _newPlayer = action.data.player
      _playerNames = action.data.allPlayers
      if _newPlayer
        Announcer.announcePlayer _newPlayer
    when ActionTypes.RECEIVE_PLAYER_NAMES
      _playerNames = action.data.playerNames
    when ActionTypes.RECEIVE_NEW_PLAYER
      _createdPlayer = action.data
      _newPlayer = action.data.name
      _playerNames.push action.data.name
      _unrecognized = undefined
    when ActionTypes.RECEIVE_SCORE_UPDATE
      _newPlayer = undefined
    when ActionTypes.RECEIVE_MATCH_ERROR
      if action.data.status is 'timeout'
        _newPlayer = undefined
        _playerNames = []
        _didTimeout = true
    when ActionTypes.RECEIVE_NFC_ERROR
      _unrecognized = action.data.nfc
  PlayerStore.emitChange()
  return
)

module.exports = PlayerStore