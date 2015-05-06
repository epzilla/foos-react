Rest = require './rest-service'
ServerActionCreator = require 'scripts/actions/server-action-creator'
socket = require 'scripts/utils/socket'
ls = require 'scripts/utils/local-storage'
random = require 'scripts/utils/random'

# Polyfill for String.startsWith function
if !String::includes

  String::includes = ->
    String::indexOf.apply(this, arguments) != -1

module.exports =

  getCurrentMatch: ->
    self = this
    Rest.get '/api/matches/current'
      .then (res) ->
        ServerActionCreator.receiveCurrentMatch res
        if res and res.team1 and res.team2
          self.getSeriesHistory res.team1._id, res.team2._id

  getSeriesHistory: (team1, team2) ->
    Rest.get('/api/matches/series/?team1=' + team1 + '&team2=' + team2)
      .then (res) ->
        ServerActionCreator.receiveSeriesHistory res

  getRecentMatches: ->
    Rest.get '/api/matches/recent'
      .then (res) ->
        ServerActionCreator.receiveRecentMatches res

  getPlayers: ->
    players = ls.get 'players'
    if players
      ServerActionCreator.receivePlayers players

    Rest.get '/api/players'
      .then (res) ->
        if not players or players.length is 0 or JSON.stringify(players) isnt JSON.stringify(res)
          ls.set 'players', res
          ServerActionCreator.receivePlayers res

  getPlayerMatches: (playerID) ->
    Rest.get('/api/matchesByPlayer/' + playerID)
      .then (res) ->
        ServerActionCreator.receivePlayerMatches res

  getTeamMatches: (teamID) ->
    Rest.get('/api/matchesByTeam/' + teamID)
      .then (res) ->
        ServerActionCreator.receiveTeamMatches res

  getTeams: ->
    teams = ls.get 'teams'
    if teams
      ServerActionCreator.receiveTeams teams

    Rest.get '/api/teams'
      .then (res) ->
        if not teams or teams.length is 0 or JSON.stringify(teams) isnt JSON.stringify(res)
          ls.set 'teams', res
          ServerActionCreator.receiveTeams res

  getPlayersInPool: ->
    Rest.get '/api/matches/playersInPool'
      .then (res) ->
        if res.length and res.length > 0
          ServerActionCreator.receivePlayersInPool res

  getHomeData: ->
    self = this
    self.getCurrentMatch()
    self.getRecentMatches()
    self.getPlayersInPool()

  changeScore: (info) ->
    if socket.connected
      socket.emit 'changeScoreUsingCode', info
    else
      ServerActionCreator.offlineScoreUpdate info

  startMatch: (players) ->
    self = this
    Rest.post('/api/matches', players)
      .then (res) ->
        ls.set 'matchID', res._id
        self.getHomeData()

  registerPlayerNFC: (nfc, player) ->
    Rest.put('/api/players/' + player, {nfc: nfc})
      .then (res) ->
        socket.emit 'playerNFC', {nfc: res.nfc}

  getCarriers: ->
    Rest.get('/api/carriers')
      .then (res) ->
        ServerActionCreator.receiveCarriers res

  registerEmailNotification: (email) ->
    Rest.post('/api/notificationByEmailAddress/', {email: email})
      .then (res) ->
        ServerActionCreator.sendAlert(
          type: 'success'
          persistent: false
          text: 'OK. An email will be sent to <strong>' + res.email + '</strong> when this match ends!')
      .catch (err) ->
        if err.includes '400'
          ServerActionCreator.sendAlert(
            type: 'warn'
            persistent: false
            text: 'We already had you down for a notification. No worries!')

  registerSMSNotification: (email) ->
    Rest.post('/api/notificationBySMS/', {email: email})
      .then (res) ->
        rawNum = res.email.split('@')[0]
        num = rawNum.slice(0, 3) + '-' + rawNum.slice(3, 6) + '-' + rawNum.slice(6, 10)
        ServerActionCreator.sendAlert(
          type: 'success'
          persistent: false
          text: 'OK. A text will be sent to <strong>' + num + '</strong> when this match ends!')
      .catch (err) ->
        if err.includes '400'
          ServerActionCreator.sendAlert(
            type: 'warn'
            persistent: false
            text: 'We already had you down for a notification. No worries!')

  endMatch: (code) ->
    socket.emit 'endMatch', {code: code}

  heckle: (player) ->
    if player
      socket.emit 'heckle', {player: player, type: 'specific'}
    else
      socket.emit 'heckle', {type: 'generic'}
