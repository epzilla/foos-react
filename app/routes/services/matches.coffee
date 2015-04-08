Match = require '../../models/match'
Team = require '../../models/team'
TeamService = require './teams'
PlayerService = require './players'
SoundService = require './sounds'
Utils = require './utils'
moment = require 'moment'
_ = require 'lodash'
MatchService = {}
timer = undefined
errString = ''
playerPool = []
playerNames = []

getRandomTeamsFromPlayers = (playerList) ->
  teams = [[], []]
  if playerList.length is 4
    shuffledPlayers = _.shuffle playerList
    teams[0][0] = shuffledPlayers[0]
    teams[0][1] = shuffledPlayers[1]
    teams[1][0] = shuffledPlayers[2]
    teams[1][1] = shuffledPlayers[3]
  teams

checkMatchInProgress = (cb) ->
  Match.findOne {active: true}, (err, match) ->
    if err
      cb(err)
    else if match
      cb(null, true)
    else
      cb(null, false)

MatchService.init = (sock) ->
  MatchService.io = sock
  MatchService.io.on 'connection', (socket) ->
    clientIp = socket.request.connection.remoteAddress
    clientPort = socket.request.connection.remotePort
    console.info 'Socket connected : ' + clientIp + ':' + clientPort
    socket.on 'scoreChange', (data) ->
      MatchService.changeScore socket, data
      return
    socket.on 'scoreBatchUpdate', (data) ->
      MatchService.update socket, data
      return
    socket.on 'playerNFC', (data) ->
      MatchService.addPlayerToPool data
      return
    socket.on 'disconnect', ->
      console.info 'Socket disconnected : ' + clientIp + ':' + clientPort
      return
    return
  return

MatchService.addPlayerToPool = (data) ->
  ###
  # First, check if match is already in progress.
  # If so, do nothing and return. Else, go ahead and try to add them
  ###
  checkMatchInProgress (err, inProgress) ->
    if err
      MatchService.io.emit 'matchError',
        status: 'matchError'
        err: err
    else if inProgress
      MatchService.io.emit 'matchError',
        status: 'matchInProgress'
        err: 'Match Already in Progress'
    else
      # Look up player by NFC ID
      PlayerService.findByNFC data.nfc, (err, player) ->
        if err
          MatchService.io.emit 'matchError',
            status: 'playerNotFound'
            err: err

        if player
          # Make sure that player hasn't already been added
          if playerPool.indexOf(player._id.toString()) is -1
            # Clear the timeout
            if timer
              clearTimeout timer

            # Add players to the pool
            playerPool.push player._id.toString()
            playerNames.push player.name
            console.info('Players in pool: ' + playerNames.toString())

            # If we have enough players to start a match, then start it
            if playerPool.length is 4
              console.info('Start Match With: ' + playerNames.toString())
              # Start new match with those players
              MatchService.createRandomWithPlayers playerPool
              playerPool = []
              playerNames = []
            else
              ###
              # Set a timeout that will reset the player pool if enough
              # players don't register within the given time
              ###
              timer = setTimeout( ->
                playerPool = []
                playerNames = []
                errString = 'Timed out. Please try adding players again.'
                console.warn errString
                MatchService.io.emit 'matchError',
                  status: 'timeout'
                  err: errString
              , 120000)
          else
            # A player's NFC tag registered more than once
            errString = 'Registered NFC event for ' + player.name +
                            ', but player is already in pool.'
            console.warn errString
            MatchService.io.emit 'matchError',
              status: 'duplicatePlayer'
              err: errString
        else
          MatchService.io.emit 'matchError',
            status: 'playerNotFound'
            err: 'Could not find player by NFC ID'
      return

MatchService.create = (req, res) ->
  now = moment()
  TeamService.getOrCreate req.body.team1, (err, team1) ->
    if err
      res.status(400).send err
    TeamService.getOrCreate req.body.team2, (err, team2) ->
      if err
        res.status(400).send err
      match = new Match(
        team1: team1._id
        team2: team2._id
        winner: null
        scores: [ {
          team1: 0
          team2: 0
        } ]
        startTime: now
        endTime: null
        gameStartTime: now
        gameNum: 1
        active: true)
      match.save (err, newMatch) ->
        if err
          res.send err
        Match.findById(newMatch._id).populate('team1 team2').exec (err, match) ->
          if err
            res.send err
          SoundService.getRandomStartGameSound (err, file) ->
            MatchService.io.emit 'matchUpdate',
              status: 'new'
              sound: file
              updatedMatch: match
          res.json match
          return
        return
      return
    return
  return

MatchService.createRandomWithPlayers = (playerList) ->
  now = moment()
  teams = getRandomTeamsFromPlayers playerList
  TeamService.getOrCreate teams[0], (err, team1) ->
    if err
      MatchService.io.emit 'matchError',
        status: 'teamNotFound'
        err: err
    TeamService.getOrCreate teams[1], (err, team2) ->
      if err
        MatchService.io.emit 'matchError',
          status: 'teamNotFound'
          err: err

      match = new Match(
        team1: team1._id
        team2: team2._id
        winner: null
        scores: [ {
          team1: 0
          team2: 0
        } ]
        startTime: now
        endTime: null
        gameStartTime: now
        gameNum: 1
        active: true)

      match.save (err, newMatch) ->
        if err
          MatchService.io.emit 'matchError',
            status: 'matchSaveError'
            err: err

        Match.findById(newMatch._id).populate('team1 team2').exec (err, match) ->
          if err
            MatchService.io.emit 'matchError',
              status: 'matchSaveError'
              err: err

          SoundService.getRandomStartGameSound (err, file) ->
            MatchService.io.emit 'matchUpdate',
              status: 'new'
              sound: file
              updatedMatch: match
          return
        return
      return
    return
  return

MatchService.findAll = (req, res) ->
  Match.find().populate('team1 team2').exec (err, matches) ->
    if err
      res.send err
    res.json matches
    return
  return

MatchService.find = (req, res) ->
  Match.findById(req.params.matchId).populate('team1 team2').exec (err, match) ->
    if err
      res.send err
    res.json match
    return
  return

MatchService.update = (sock, data) ->
  Match.findById data._id, (err, match) ->
    if err
      sock.emit 'matchError',
        status: 'matchUpdateFailed'
        err: err
    else
      for prop of data
        if data.hasOwnProperty(prop)
          # We want to leave teams alone, but allow point updates
          if match[prop] != undefined and !(prop == 'team1' or prop == 'team2')
            match[prop] = data[prop]
      match.save (err, updatedMatch) ->
        if err
          sock.emit 'matchError',
            status: 'matchUpdateFailed'
            err: err
        else
          MatchService.io.emit 'matchUpdate',
            status: 'ok'
            updatedMatch: updatedMatch
        return
    return
  return

MatchService.getRecentMatches = (req, res) ->
  Match.find(active: false).sort('endTime': 'desc').limit(req.param('num') or 10).populate('team1 team2').exec (err, matches) ->
    if err
      res.send err
    res.json matches
    return
  return

MatchService.getCurrentMatch = (req, res) ->
  Match.find(active: true).populate('team1 team2').exec (err, match) ->
    if err
      res.send err
    res.json match
    return
  return

MatchService.endMatch = (sock, match) ->
  newScore = match.score or
    team1: 0
    team2: 0
  gameNum = match.gameNum or 3
  matchOver = gameNum == 3
  Match.findById match._id, (err, match) ->
    if err
      sock.emit 'matchError',
        status: 'matchNotFound'
        err: err
    match.scores.push newScore
    match.gameNum = gameNum
    if matchOver
      match.active = false
    match.save (err, updatedMatch) ->
      if err
        sock.emit 'matchError',
          status: 'matchUpdateFailed'
          rollback: match
          err: err
      if matchOver
        MatchService.io.emit 'matchUpdate',
          status: 'finished'
          updatedMatch: updatedMatch
      else
        MatchService.io.emit 'matchUpdate',
          status: 'ok'
          updatedMatch: updatedMatch
      return
    return
  return

# MatchService.incrementScore = (req, res) ->
#   Match.find(active: true).populate('team1 team2').exec (err, match) ->
#     if err
#       res.send err
#     if match


###
# changeScore - update the score of a game
# @param  {socket.io socket} sock
# @param  {Object} data
#         {
#           id: Mongoose ObjecId
#           team: ['team1', 'team2']
#           plusMinus: ['plus', 'minus']
#         }
###
MatchService.changeScore = (sock, data) ->
  Match.findOne {active:true}, (err, match) ->
    if err
      sock.emit 'matchError',
        status: 'matchNotFound'
        err: err
    team = [ data.team ]
    rollbackScore = match.scores[match.gameNum - 1][team]
    gameOver = false
    # Increment or decrement the specified team's score
    if data.plusMinus == 'plus'
      match.scores[match.gameNum - 1][team]++
    else
      match.scores[match.gameNum - 1][team]--
    # If it's the last game, end it; otherwise, move to the next game
    if match.scores[match.gameNum - 1][team] == 10
      gameOver = true
      if match.gameNum == 3
        statPack =
          team1:
            id: match.team1
            gameWins: 0
            pts: 0
            isWinner: false
          team2:
            id: match.team1
            gameWins: 0
            pts: 0
            isWinner: false
        match.active = false
        match.endTime = moment()
        # Loop through each game in the match and collect stats
        match.scores.forEach (score) ->
          if score.team1 > score.team2
            statPack.team1.gameWins++
          else
            statPack.team2.gameWins++
          statPack.team1.pts += score.team1
          statPack.team2.pts += score.team2
          return
        # Determine the winner
        if statPack.team1.gameWins > statPack.team2.gameWins
          match.winner = match.team1
          statPack.team1.isWinner = true
        else
          match.winner = match.team2
          statPack.team2.isWinner = true
      else
        match.gameNum++
        match.gameStartTime = moment()
        match.scores.push
          team1: 0
          team2: 0
    match.save (err, updatedMatch) ->
      # If there was an error, roll back the score
      if err
        sock.emit 'matchError',
          status: 'matchUpdateFailed'
          rollback:
            team: team
            score: rollbackScore
          err: err
      # Otherwise, broadcast the update
      if !updatedMatch.active
        # Match is over
        TeamService.updateTeamStats updatedMatch, statPack, (err, teams, winnerID) ->
          if err
            sock.emit 'matchError',
              status: 'matchUpdateFailed'
              rollback:
                team: team
                score: rollbackScore
              err: err
          PlayerService.updatePlayerStats updatedMatch, teams, statPack, (err) ->
            if err
              sock.emit 'matchError',
                status: 'matchUpdateFailed'
                rollback:
                  team: team
                  score: rollbackScore
                err: err
            else
              w = if teams[0]._id.equals(winnerID) then teams[0] else teams[1]
              SoundService.getRandomEndGameSound (err, file) ->
                MatchService.io.emit 'matchUpdate',
                  status: 'finished'
                  winner: w
                  sound: file
                  updatedMatch: updatedMatch
            return
          return
      else
        # Match continues
        SoundService.getRandomGoalSound( (err, file) ->
          MatchService.io.emit 'matchUpdate',
            status: 'ok'
            updatedMatch: updatedMatch
            sound: file
            whatChanged:
              team: team[0]
              plusMinus: data.plusMinus
              gameOver: gameOver
          return
        )
      return
    return
  return

MatchService.getSeriesHistory = (req, res) ->
  team1 = req.param('team1')
  team2 = req.param('team2')
  Team.findById team1, (err, t1) ->
    if err
      res.status(400).send err
    Team.findById team2, (err, t2) ->
      if err
        res.status(400).send err
      Match.find($and: [
        { 'team1': $in: [
          t1
          t2
        ] }
        { 'team2': $in: [
          t1
          t2
        ] }
        { 'active': false }
      ]).sort('endTime': 'desc').limit(req.param('num') or 10).populate('team1 team2').exec (err, matches) ->
        if err
          res.send err
        # res.json(matches);
        numGames = 0
        team1agg = 0
        team1avg = 0
        team1wins = 0
        team1losses = 0
        team1gameWins = 0
        team1gameLosses = 0
        team2agg = 0
        team2avg = 0
        team2wins = 0
        team2losses = 0
        team2gameWins = 0
        team2gameLosses = 0
        quickStats = {}
        matches.forEach (match) ->
          if match.team1._id.equals(t1._id)
            if match.winner.equals(match.team1._id)
              team1wins++
              team2losses++
            else if match.winner.equals(match.team2._id)
              team2wins++
              team1losses++
            match.scores.forEach (score) ->
              if score.team1 > score.team2
                team1gameWins++
                team2gameLosses++
              else if score.team2 > score.team1
                team2gameWins++
                team1gameLosses++
              team1agg += score.team1
              team2agg += score.team2
              numGames++
              return
          else if match.team1._id.equals(t2._id)
            if match.winner.equals(match.team1._id)
              team2wins++
              team1losses++
            else if match.winner.equals(match.team2._id)
              team1wins++
              team2losses++
            match.scores.forEach (score) ->
              if score.team1 > score.team2
                team2gameWins++
                team1gameLosses++
              else if score.team2 > score.team1
                team1gameWins++
                team2gameLosses++
              team2agg += score.team1
              team1agg += score.team2
              numGames++
              return
          return
        team1avg = team1agg / numGames
        team2avg = team2agg / numGames
        if team1wins > team2wins
          quickStats.matchRecord = t1.title + ' lead ' + team1wins + '-' + team2wins
        else if team2wins > team1wins
          quickStats.matchRecord = t2.title + ' lead ' + team2wins + '-' + team1wins
        else
          quickStats.matchRecord = 'Series tied: ' + team1wins + '-' + team2wins
        if team1gameWins > team2gameWins
          quickStats.gameRecord = t1.title + ' lead ' + team1gameWins + '-' + team2gameWins
        else if team2gameWins > team1gameWins
          quickStats.gameRecord = t2.title + ' lead ' + team2gameWins + '-' + team1gameWins
        else
          quickStats.gameRecord = 'Tied: ' + team1gameWins + '-' + team2gameWins
        if team1avg > team2avg
          quickStats.avg = t1.title + ' ' + team1avg.toFixed(1) + '-' + team2avg.toFixed(1)
        else if team2avg > team1avg
          quickStats.avg = t2.title + ' ' + team2avg.toFixed(1) + '-' + team1avg.toFixed(1)
        else
          quickStats.avg = 'Dead even at ' + team2avg.toFixed(1) + '-' + team1avg.toFixed(1)
        payload =
          matches: matches
          stats:
            team1:
              team: t1
              wins: team1wins
              losses: team1losses
              gameWins: team1gameWins
              gameLosses: team1gameLosses
              avgScore: team1avg
            team2:
              team: t2
              wins: team2wins
              losses: team2losses
              gameWins: team2gameWins
              gameLosses: team2gameLosses
              avgScore: team2avg
          quickStats: quickStats
        res.json payload
        return
      return
    return
  return

module.exports = MatchService