Constants = require 'scripts/constants/constants'
EventEmitter = require('events').EventEmitter
assign = require 'object-assign'
Dispatcher = require 'scripts/dispatcher/app-dispatcher'
Announcer = require 'scripts/utils/announcer'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'change'
_ = require 'lodash'

_players = []
_playerMatches = []


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

  addChangeListener: (callback) ->
    @on CHANGE_EVENT, callback

  removeChangeListener: (callback) ->
    @removeListener CHANGE_EVENT, callback

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

  getPlayerInfo: (id) ->
    _.find(_players, {_id: id})

  getPlayerMatches: (id) ->
    _playerMatches
)

PlayerStore.dispatchToken = Dispatcher.register( (payload) ->
  action = payload.action
  switch action.type
    when ActionTypes.RECEIVE_PLAYERS
      _players = action.data
      _playerEmails = _.uniq(_.pluck _players, 'email')
      _newPlayer = undefined

    when ActionTypes.RECEIVE_PLAYERS_IN_POOL
      if action.data and action.data.length and action.data.length > 0
        _playerNames = action.data
      else
        _newPlayer = undefined

      if _playerNames.length > 0
        _newPlayer = _playerNames[_playerNames.length - 1]

    when ActionTypes.RECEIVE_REGISTERED_PLAYER
      _newPlayer = action.data.player
      _playerNames = action.data.allPlayers

      if _newPlayer
        Announcer.announcePlayer _newPlayer

    when ActionTypes.RECEIVE_PLAYER_NAMES
      _playerNames = action.data.playerNames

      if _playerNames.length is 4
        _newPlayer = undefined

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

    when ActionTypes.RECEIVE_PLAYER_MATCHES
      _playerMatches = action.data

  PlayerStore.emitChange()
)

module.exports = PlayerStore