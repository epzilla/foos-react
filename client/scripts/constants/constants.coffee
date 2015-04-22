keyMirror = require 'keymirror'

module.exports =

  ActionTypes: keyMirror(
    RECEIVE_HOME_DATA: null
    RECEIVE_CURRENT_MATCH: null
    RECEIVE_RECENT_MATCHES: null
    RECEIVE_SCORE_UPDATE: null
    RECEIVE_SERIES_HISTORY: null
    RECEIVE_REGISTERED_PLAYER: null
    RECEIVE_NEW_PLAYER: null
    RECEIVE_PLAYERS: null
    RECEIVE_PLAYER_NAMES: null
    RECEIVE_PREDICTION: null
    RECEIVE_TEAMS: null
    RECEIVE_MATCH_ERROR: null
    RECEIVE_NFC_ERROR: null
    RECEIVE_CARRIERS: null
    EMAIL_REGISTERED: null
    CHANGE_SCORE: null
    RECEIVE_ALERT: null
    CLEAR_ALERTS: null
    OFFLINE_SCORE_UPDATE: null
  )

  PayloadSources: keyMirror(
    SERVER_ACTION: null
    VIEW_ACTION: null
    REQUEST_ACTION: null
  )