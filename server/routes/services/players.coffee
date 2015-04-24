Player = require '../../models/player'
_ = require 'lodash'
fs = require 'fs'

module.exports =
  init: ->
    Player.count (err, count) ->
      if !err and count is 0
        fs.readFile 'conf/players.csv', (err, data) ->
          if err
            throw err
          array = data.toString().split('\n')
          players = []
          array.forEach (ln) ->
            if ln and ln isnt ''
              lnParts = ln.split(',')
              name = lnParts[0]
              if lnParts.length > 1
                email = lnParts[1]
              else
                firstlast = name.split ' '
                email = firstlast[0] + '.' + firstlast[1] + '@synapse-wireless.com'
              nfc = if lnParts.length > 2 then lnParts[2] else ''
              players.push
                'avgPtsAgainst': 0
                'avgPtsFor': 0
                'nfc': nfc
                'email': email
                'games': 0
                'gamesWon': 0
                'gamesLost': 0
                'ptsFor': 0
                'img': '/images/players/default.jpg'
                'matches': 0
                'matchesLost': 0
                'matchesWon': 0
                'name': name
                'pct': 0
                'ptsAgainst': 0
                'rating': 1000
                'rank': null

          Player.collection.insert players, (err, playerList) ->
            if err
              throw err
            console.info 'Seeded list of players'

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

  findAll: (req, res) ->
    Player.find().sort('name': 'asc').exec (err, players) ->
      if err
        res.send err
      res.json players

  find: (req, res) ->
    Player.findById req.params.playerId, (err, player) ->
      if err
        res.send err
      res.json player

  findByNFC: (nfc, cb) ->
    Player.findOne {nfc: nfc}, (err, player) ->
      if err
        console.error err
        cb err
      cb(null, player)

  update: (req, res) ->
    Player.findById req.params.playerId, (err, player) ->
      if err
        res.send err
      newVals = req.body
      for prop of newVals
        if newVals.hasOwnProperty(prop)
          player[prop] = newVals[prop]
      player.save (err, updatedPlayer) ->
        if err
          res.send err
        res.json updatedPlayer

  updateByName: (req, res) ->
    Player.findOne {name: req.params.name}, (err, player) ->
      if err
        res.send err
      newVals = req.body
      for prop of newVals
        if newVals.hasOwnProperty(prop)
          player[prop] = newVals[prop]
      player.save (err) ->
        if err
          res.send err
        res.json message: 'Player updated!'

  updatePlayerStats: (match, teams, statPack, cb) ->
    team1 = undefined
    team2 = undefined

    # Create one master list of players from the two teams
    playerIdList = teams[0].players.slice()
    teams0StringIDList = []

    playerIdList.forEach (objId) ->
      teams0StringIDList.push objId.toString()

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

      players.forEach (player) ->
        plTeam = undefined
        oppTeam = undefined
        player.matches++
        player.games += match.scores.length

        if _.contains(teams0StringIDList, player._id.toString())
          # This player was on team 1
          plTeam = statPack.team1
          oppTeam = statPack.team2
          player.rating += statPack.team1RatingChange
        else
          plTeam = statPack.team2
          oppTeam = statPack.team1
          player.rating += statPack.team2RatingChange

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

  resetOneByName: (req, res) ->
    Player.findOne {'name': req.params.name}, (err, player) ->
      if err
        res.send err

      if not player.nfc
        player.nfc = ''
      player.avgPtsFor = 0.0
      player.avgPtsAgainst = 0.0
      player.games = 0
      player.gamesLost = 0
      player.gamesWon = 0
      player.matches = 0
      player.matchesLost = 0
      player.matchesWon = 0
      player.pct = 0.000
      player.ptsFor = 0
      player.ptsAgainst = 0
      player.rank = null
      player.rating = 1000
      player.save (err, updatedPlayer) ->
        if err
          res.status(500).send()

        res.status(200).json updatedPlayer

  resetOneById: (req, res) ->
    Player.findOne {_id: req.params.id}, (err, player) ->
      if err
        res.send err

      player.avgPtsFor = 0.0
      player.avgPtsAgainst = 0.0
      player.games = 0
      player.gamesLost = 0
      player.gamesWon = 0
      player.matches = 0
      player.matchesLost = 0
      player.matchesWon = 0
      player.pct = 0.000
      player.ptsFor = 0
      player.ptsAgainst = 0
      player.rank = null
      player.rating = 1000
      pl.save (err) ->
        if err
          res.status(500).send()

        res.status(200).send()

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
        pl.rank = null
        pl.rating = 1000
        pl.ptsAgainst = 0
        pl.save (err) ->
          if err
            res.status(500).send()
          plNum++
          if plNum == numPlayers
            res.status(200).send()

  reRank: ->
    console.log 'Re-ranking players...'
    Player.find()
      .where('matches').gt(0)
      .sort({'rating': 'desc'})
      .exec (err, players) ->
        i = 0
        prevRating = -1
        prevRanking = -1

        while i < players.length
          pl = players[i]

          if pl.rating isnt prevRating
            pl.rank = i + 1
            prevRanking = i + 1
            prevRating = pl.rating
          else
            pl.rank = prevRanking

          console.log(pl.name + ' now ranks: ' + pl.rank)

          pl.save (err, updatedPlayer) ->
            if err
              console.error err

          i++
