keyMirror = require 'keymirror'

module.exports =

  ActionTypes: keyMirror(
    RECEIVE_HOME_DATA: null
    RECEIVE_CURRENT_MATCH: null
    RECEIVE_RECENT_MATCHES: null
    RECEIVE_SCORE_UPDATE: null
    RECEIVE_SERIES_HISTORY: null
    RECEIVE_PLAYERS: null
    RECEIVE_TEAMS: null
    CHANGE_SCORE: null
    RECEIVE_ALERT: null
    CLEAR_ALERTS: null
  )

  PayloadSources: keyMirror(
    SERVER_ACTION: null
    VIEW_ACTION: null
    REQUEST_ACTION: null
  )