Player = require('../../models/player')
_ = require('lodash')

module.exports =
  create: (req, res) ->
    player = new Player(
      name: req.body.name
      matches: 0
      games: 0
      matchesWon: 0
      matchesLost: 0
      gamesWon: 0
      gamesLost: 0
      pct: 0
      ptsFor: 0
      ptsAgainst: 0)
    player.save (err) ->
      if err
        res.send err
      res.json message: 'Player created!'
      return
    return
  findAll: (req, res) ->
    Player.find().sort('name': 'asc').exec (err, players) ->
      if err
        res.send err
      res.json players
      return
    return
  find: (req, res) ->
    Player.findById req.params.playerId, (err, player) ->
      if err
        res.send err
      res.json player
      return
    return
  update: (req, res) ->
    Player.findById req.params.playerId, (err, player) ->
      if err
        res.send err
      newVals = req.body
      for prop of newVals
        if newVals.hasOwnProperty(prop)
          if player[prop] != undefined
            player[prop] = newVals[prop]
      player.save (err) ->
        if err
          res.send err
        res.json message: 'Player updated!'
        return
      return
    return
  updatePlayerStats: (match, teams, statPack, cb) ->
    team1 = undefined
    team2 = undefined
    # Create one master list of players from the two teams
    playerIdList = teams[0].players.slice()
    teams0StringIDList = []
    playerIdList.forEach (objId) ->
      teams0StringIDList.push objId.toString()
      return
    playerIdList.push.apply playerIdList, teams[1].players
    #Match up the teams
    if teams[0]._id.equals(match.team1)
      team1 = teams[0]
      team2 = teams[1]
    else
      team1 = teams[1]
      team2 = teams[0]
    Player.find { _id: $in: playerIdList }, (err, players) ->
      if err
        cb err, null
        return
      players.forEach (player) ->
        plTeam = undefined
        oppTeam = undefined
        player.matches++
        player.games += match.scores.length
        if _.contains(teams0StringIDList, player._id.toString())
          # This player was on team 1
          plTeam = statPack.team1
          oppTeam = statPack.team2
        else
          plTeam = statPack.team2
          oppTeam = statPack.team1
        player.gamesWon += plTeam.gameWins
        player.gamesLost += oppTeam.gameWins
        player.ptsFor += plTeam.pts
        player.ptsAgainst += oppTeam.pts
        if plTeam.isWinner
          player.matchesWon++
        else
          player.matchesLost++
        player.pct = parseFloat((player.matchesWon / player.matches).toFixed(3))
        player.avgPtsFor = parseFloat((player.ptsFor / player.games).toFixed(2))
        player.avgPtsAgainst = parseFloat((player.ptsAgainst / player.games).toFixed(2))
        return
      # Hack for now, because mongoose doesn't support batch updates
      # We know there are 4 players, so we're just going to
      # hard-code a pyramid of doom
      if players.length == 4
        players[0].save (err) ->
          if err
            cb err, null
          players[1].save (err) ->
            if err
              cb err, null
            players[2].save (err) ->
              if err
                cb err, null
              players[3].save (err) ->
                if err
                  cb err, null
                cb()
                return
              return
            return
          return
      return
    return
  resetAll: (req, res) ->
    Player.find (err, players) ->
      if err
        res.send err
      numPlayers = players.length
      plNum = 0
      players.forEach (pl) ->
        pl.avgPtsFor = 0.0
        pl.avgPtsAgainst = 0.0
        pl.games = 0
        pl.gamesLost = 0
        pl.gamesWon = 0
        pl.matches = 0
        pl.matchesLost = 0
        pl.matchesWon = 0
        pl.pct = 0.000
        pl.ptsFor = 0
        pl.ptsAgainst = 0
        pl.save (err) ->
          if err
            res.status(500).send()
          plNum++
          if plNum == numPlayers
            res.status(200).send()
          return
        return
      return
    return