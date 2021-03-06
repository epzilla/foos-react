Match = require '../../models/match'
Team = require '../../models/team'
Player = require '../../models/player'
TeamService = require './teams'
PlayerService = require './players'
SoundService = require './sounds'
EmailService = require './email'
Utils = require './utils'
conf = require '../../conf/config'
moment = require 'moment'
_ = require 'lodash'
mongoose = require 'mongoose'
deepPopulate = require 'mongoose-deep-populate'
ObjectId = mongoose.Types.ObjectId

MatchService = {}
timer = undefined
errString = ''
playerIdPool = []
playerNames = []
playerPool = []
teamMap = undefined
code = ''

getRandomTeamsFromPlayers = (playerList) ->
  teams = [[], []]
  if playerList.length is 4
    shuffledPlayers = _.shuffle playerList
    teams[0][0] = shuffledPlayers[0]
    teams[0][1] = shuffledPlayers[1]
    teams[1][0] = shuffledPlayers[2]
    teams[1][1] = shuffledPlayers[3]
  teams

getRandomCode = ->
  code = Math.random().toString(36).substring(2, 10)
  code

checkMatchInProgress = (cb) ->
  Match.findOne {active: true}, (err, match) ->
    if err
      cb(err)
    else if match
      cb(null, true)
    else
      cb(null, false)

sendPlayerNames = (match) ->
  currentPlayers = match.team1.players
  Array.prototype.push.apply currentPlayers, match.team2.players
  pNames = _.pluck currentPlayers, 'name'
  plNames = pNames.map (pl) ->
    pl = pl.split(' ')[0]
  MatchService.io.emit 'playerNames',
    playerNames: plNames

MatchService.init = (sock) ->
  MatchService.io = sock
  teamMap = conf.TEAM_MAP
  MatchService.io.on 'connection', (socket) ->
    clientIp = socket.request.connection.remoteAddress
    clientPort = socket.request.connection.remotePort
    console.info 'Socket connected : ' + clientIp + ':' + clientPort

    socket.on 'scoreChange', (data) ->
      MatchService.changeScore socket, data

    socket.on 'changeScoreUsingCode', (data) ->
      MatchService.changeScoreUsingCode socket, data

    socket.on 'scoreBatchUpdate', (data) ->
      MatchService.update socket, data

    socket.on 'playerNFC', (data) ->
      MatchService.addPlayerToPool data

    socket.on 'endMatch', (data) ->
      MatchService.endMatch data

    socket.on 'heckle', (data) ->
      MatchService.io.emit 'announceHeckle', data

    socket.on 'disconnect', ->
      console.info 'Socket disconnected : ' + clientIp + ':' + clientPort

MatchService.getPlayersInPool = (req, res) ->
  res.json playerNames

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
          if playerIdPool.indexOf(player._id.toString()) is -1
            # Clear the timeout
            if timer
              clearTimeout timer

            # Add players to the pool
            playerIdPool.push player._id.toString()
            playerNames.push player.name
            playerPool.push player
            console.info('Players in pool: ' + playerNames.toString())

            # If we have enough players to start a match, then start it
            if playerIdPool.length is 4
              console.info('Start Match With: ' + playerNames.toString())
              # Start new match with those players
              MatchService.io.emit 'playerNames',
                playerNames: playerNames

              MatchService.createRandomWithPlayers playerIdPool, (err, match) ->
                if err
                  console.error err

                prediction = match.prediction

                if prediction.action is 'tie'
                  console.log('Prediction is too close to call between ' +
                              match.team1.title + ' and ' + match.team2.title)
                else
                  console.log('Predict ' + prediction.winner.title + ' to ' +
                              prediction.action + ' ' + prediction.loser.title)

                MatchService.io.emit 'prediction',
                  prediction: prediction

                EmailService.sendStartMatchEmail playerPool, code, (err, players) ->
                  playerIdPool = []
                  playerNames = []
                  playerPool = []
            else
              ###
              # Set a timeout that will reset the player pool if enough
              # players don't register within the given time
              ###
              timer = setTimeout( ->
                playerIdPool = []
                playerNames = []
                errString = 'Timed out. Please try adding players again.'
                console.warn errString
                MatchService.io.emit 'matchError',
                  status: 'timeout'
                  err: errString
              , 120000)

              # Send a socket message so the UI can show that a player has registered
              MatchService.io.emit 'playerRegistered',
                player: player.name
                allPlayers: playerNames

          else
            # A player's NFC tag registered more than once
            errString = 'Registered NFC event for ' + player.name +
                            ', but player is already in pool.'
            console.warn errString
            MatchService.io.emit 'matchError',
              status: 'duplicatePlayer'
              err: errString
        else
          MatchService.io.emit 'nfcError',
            status: 'playerNotFound'
            nfc: data.nfc
            err: 'Could not find player by NFC ID'

MatchService.create = (req, res) ->
  now = moment()
  TeamService.getOrCreate req.body.team1, (err, team1) ->
    if err
      res.status(400).send err
    TeamService.getOrCreate req.body.team2, (err, team2) ->
      if err
        res.status(400).send err
      playerIDs = req.body.team1
      Array.prototype.push.apply playerIDs, req.body.team2
      prediction = Utils.getPrediction(team1, team2)
      console.log prediction

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
        players: playerIDs
        prediction: prediction
        gameNum: 1
        active: true)

      match.save (err, newMatch) ->
        if err
          res.send err

        Match.deepPopulate newMatch, 'team1.players team2.players', (err, populatedMatch) ->
          if err
            res.status(500).send err

          SoundService.getRandomStartGameSound (err, file) ->
            MatchService.io.emit 'matchUpdate',
              status: 'new'
              sound: file
              updatedMatch: populatedMatch

            populatedMatch.team1.players.forEach (pl) ->
              playerPool.push pl

            populatedMatch.team2.players.forEach (pl) ->
              playerPool.push pl

            sendPlayerNames populatedMatch

            code = getRandomCode()

            if prediction.action is 'tie'
              console.log('Prediction is too close to call between ' +
                          populatedMatch.team1.title + ' and ' + populatedMatch.team2.title)
            else
              console.log('Predict ' + prediction.winner.title + ' to ' +
                          prediction.action + ' ' + prediction.loser.title)

            MatchService.io.emit 'prediction',
              prediction: prediction

            EmailService.sendStartMatchEmail playerPool, code, (err, players) ->
              playerIdPool = []
              playerNames = []
              playerPool = []

              res.json populatedMatch

MatchService.createRandomWithPlayers = (playerList, cb) ->
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

      prediction = Utils.getPrediction(team1, team2)

      match = new Match(
        team1: team1._id
        team2: team2._id
        winner: null
        scores: [ {
          team1: 0
          team2: 0
        } ]
        players: playerList
        startTime: now
        endTime: null
        gameStartTime: now
        gameNum: 1
        active: true,
        prediction: prediction)

      match.save (err, newMatch) ->
        if err
          MatchService.io.emit 'matchError',
            status: 'matchSaveError'
            err: err

        Match.deepPopulate newMatch, 'team1.players team2.players', (err, populatedMatch) ->
          if err
            MatchService.io.emit 'matchError',
              status: 'matchSaveError'
              err: err

          SoundService.getRandomStartGameSound (err, file) ->
            MatchService.io.emit 'matchUpdate',
              status: 'new'
              sound: file
              updatedMatch: populatedMatch

            sendPlayerNames populatedMatch

            code = getRandomCode()
            cb(null, match)

MatchService.findAll = (req, res) ->
  Match.find().populate('team1 team2').exec (err, matches) ->
    if err
      res.send err
    res.json matches

MatchService.find = (req, res) ->
  Match.findById(req.params.matchId).populate('team1 team2').exec (err, match) ->
    if err
      res.send err
    res.json match

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

MatchService.delete = (id) ->
  Match.findByIdAndRemove id, (err, match) ->
    if err
      console.error err
    else
      match.active = false

      MatchService.io.emit 'matchUpdate',
        status: 'aborted'
        updatedMatch: match

      EmailService.fireAbortNotifications(match)

MatchService.getRecentMatches = (req, res) ->
  Match.find(active: false)
    .sort('endTime': 'desc')
    .limit(req.param('num') or 10)
    .populate('team1 team2').exec (err, matches) ->
      if err
        res.send err
      res.json matches

MatchService.getCurrentMatch = (req, res) ->
  Match.findOne(active: true).populate('team1 team2').exec (err, match) ->
    if err
      res.send err
    if match
      Match.deepPopulate match, 'team1.players team2.players', (err, populatedMatch) ->
        sendPlayerNames populatedMatch
        res.json populatedMatch
    else
      res.json {}

MatchService.endMatch = (data) ->
  if data.code is code
    # If 2 games were finished, and the same team won them, we have a winner
    Match.findOne {active: true}, (err, match) ->
      if match
        match.active = false
        match.endTime = moment()

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

        # Loop through each game in the match and collect stats
        match.scores.forEach (score) ->
          if score.team1 > score.team2
            statPack.team1.gameWins++
          else
            statPack.team2.gameWins++

          statPack.team1.pts += score.team1
          statPack.team2.pts += score.team2

        if statPack.team1.gameWins > 1
          match.winner = match.team1
          statPack.team1.isWinner = true
        else if statPack.team2.gameWins > 1
          match.winner = match.team2
          statPack.team2.isWinner = true

        if match.winner
          match.save (err, updatedMatch) ->
            # If there was an error, roll back the score
            if err
              sock.emit 'matchError',
                status: 'matchUpdateFailed'
                err: err

            # Otherwise, broadcast the update
            if !updatedMatch.active
              # Match is over
              code = ''

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
                      EmailService.fireNotifications(updatedMatch, teams)

            else if match.scores[match.gameNum - 1].team1 is 9 or match.scores[match.gameNum - 1].team2 is 9
              # Game Point
              SoundService.getRandomGamePointSound( (err, file) ->
                MatchService.io.emit 'matchUpdate',
                  status: 'ok'
                  updatedMatch: updatedMatch
                  sound: file
                  whatChanged:
                    team: team[0]
                    plusMinus: data.plusMinus
                    gameOver: gameOver
              )
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
              )
        else
          MatchService.delete match._id

# Increment or decrement the score from the UI
MatchService.changeScoreUsingCode = (sock, data) ->
  if data.code is code
    MatchService.changeScore(sock, data)

###
# changeScore - update the score of a game
# @param  {socket.io socket} sock
# @param  {Object} data
#         {
#           team: ('yellow' | 'black')
#           plusMinus: ('plus' | 'minus')
#         }
###
MatchService.changeScore = (sock, data) ->
  Match.findOne {active:true}, (err, match) ->
    if err
      sock.emit 'matchError',
        status: 'matchNotFound'
        err: err
    if match
      if parseInt(match.gameNum) is 2
        team = teamMap.game2[data.team]
      else
        team = teamMap.game1[data.team]

      rollbackScore = match.scores[match.gameNum - 1][team]
      gameOver = false

      # Increment or decrement the specified team's score
      if data.plusMinus == 'plus'
        match.scores[match.gameNum - 1][team]++
      else
        if match.scores[match.gameNum - 1][team] isnt 0
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
              id: match.team2
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
          code = ''


          TeamService.updateTeamStats updatedMatch, statPack, (err, teams, winnerID, newStatPack) ->
            if err
              sock.emit 'matchError',
                status: 'matchUpdateFailed'
                rollback:
                  team: team
                  score: rollbackScore
                err: err

            PlayerService.updatePlayerStats updatedMatch, teams, newStatPack, (err) ->
              if err
                sock.emit 'matchError',
                  status: 'matchUpdateFailed'
                  rollback:
                    team: team
                    score: rollbackScore
                  err: err
              else
                w = if teams[0]._id.equals(winnerID) then teams[0] else teams[1]
                l = if teams[0]._id.equals(winnerID) then teams[1] else teams[0]
                winnerName = w.title
                loserName = l.title
                t1wins = statPack.team1.gameWins
                t2wins = statPack.team2.gameWins

                if updatedMatch.winner is updatedMatch.team1
                  updatedMatch.summary = winnerName + ' defeated ' + loserName + ' ' +
                                         t1wins + ' games to ' + t2wins + '.'
                else if updatedMatch.winner is updatedMatch.team2
                  updatedMatch.summary = winnerName + ' defeated ' + loserName + ' ' +
                                         t2wins + ' games to ' + t1wins + '.'
                else
                  updatedMatch.summary = teams[0].title + ' and ' + teams[1].title + ' played to a draw.'

                SoundService.getRandomEndGameSound (err, file) ->

                  MatchService.io.emit 'matchUpdate',
                    status: 'finished'
                    winner: w
                    sound: file
                    updatedMatch: updatedMatch
                  EmailService.fireNotifications(updatedMatch, teams)
                  PlayerService.reRank()
                  TeamService.reRank()

        else if match.scores[match.gameNum - 1].team1 is 9 or match.scores[match.gameNum - 1].team2 is 9
          # Game Point
          SoundService.getRandomGamePointSound( (err, file) ->
            MatchService.io.emit 'matchUpdate',
              status: 'ok'
              updatedMatch: updatedMatch
              sound: file
              whatChanged:
                team: team[0]
                plusMinus: data.plusMinus
                gameOver: gameOver
          )
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
          )

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

MatchService.getMatchesByPlayer = (req, res) ->
  Match.find({players: req.params.playerID})
    .populate('team1 team2')
    .sort({'endTime': 'desc'})
    .exec (err, matches) ->
      if err
        res.status(500).send err
      res.json matches

MatchService.getMatchesByTeam = (req, res) ->
  Match.find( {$or: [{team1: req.params.teamID}, {team2: req.params.teamID}] })
    .populate('team1 team2')
    .sort({'endTime': 'desc'})
    .exec (err, matches) ->
      if err
        res.status(500).send err
      res.json matches

module.exports = MatchService