Team = require('../../models/team')
Player = require('../../models/player')

createNewTeam = (playerIDs, cb) ->
  title = ''
  Player.find { '_id': $in: playerIDs }, (err, players) ->
    if err
      cb err, null
    nameArray = players[0].name.split(' ')
    title += nameArray[nameArray.length - 1]
    i = 1
    while i < players.length
      nameArray = players[i].name.split(' ')
      title += ' / ' + nameArray[nameArray.length - 1]
      i++
    team = new Team(
      players: playerIDs
      title: title
      matches: 0
      games: 0
      matchesWon: 0
      matchesLost: 0
      gamesWon: 0
      gamesLost: 0
      pct: 0
      ptsFor: 0
      ptsAgainst: 0
      avgPtsFor: 0
      avgPtsAgainst: 0)
    cb null, team
    return
  return

###
# This function would be used to update stats from a match if
# we were calling it as a separate route, not calling it from
# the "matches" module, where we've already done some of the
# calculations
###

updateStatsFromMatch = (match, teams, cb) ->
  team1 = undefined
  team2 = undefined
  team1wins = 0
  team2wins = 0
  team1pts = 0
  team2pts = 0
  teams.forEach (team) ->
    team.games++
    team.matches++
    return
  if teams[0]._id.equals(match.team1)
    team1 = teams[0]
    team2 = teams[1]
  else
    team1 = teams[1]
    team2 = teams[0]
  match.scores.forEach (score) ->
    if score.team1 > score.team2
      team1wins++
    else
      team2wins++
    team1pts += score.team1
    team2pts += score.team2
    return
  if team1wins > team2wins
    match.winner = match.team1
    team1.matchesWon++
    team2.matchesLost++
  else
    match.winner = match.team2
    team2.matchesWon++
    team1.matchesLost++
  team1.gamesWon += team1wins
  team2.gamesWon += team2wins
  team1.gamesLost += team2wins
  team2.gamesLost += team1wins
  team1.ptsFor += team1pts
  team2.ptsFor += team2pts
  team1.ptsAgainst += team2pts
  team2.ptsAgainst += team1pts
  team1.pct = parseFloat((team1.matchesWon / team1.matches).toFixed(3))
  team2.pct = parseFloat((team2.matchesWon / team2.matches).toFixed(3))
  team1.save (err) ->
    if err
      cb err, null
    team2.save (err) ->
      if err
        cb err, null
      else
        cb()
      return
    return
  return

###
# This function is the one currently in use, being called from the
# "matches" module, when a match ends, and after some of the stat
# calculations have already been done. We simply pass those stats in,
# so we don't need to do them twice.
###

updateUsingStatPack = (match, teams, statPack, cb) ->
  team1 = undefined
  team2 = undefined
  winnerID = undefined
  if teams[0]._id.equals(statPack.team1.id)
    team1 = teams[0]
    team2 = teams[1]
  else
    team1 = teams[1]
    team2 = teams[0]
  if statPack.team1.isWinner
    winnerID = team1._id
    team1.matchesWon++
    team2.matchesLost++
  else
    winnerID = team2._id
    team2.matchesWon++
    team1.matchesLost++
  team1.matches++
  team2.matches++
  team1.gamesWon += statPack.team1.gameWins
  team2.gamesWon += statPack.team2.gameWins
  team1.gamesLost += statPack.team2.gameWins
  team2.gamesLost += statPack.team1.gameWins
  team1.games += match.scores.length
  team2.games += match.scores.length
  team1.ptsFor += statPack.team1.pts
  team2.ptsFor += statPack.team2.pts
  team1.ptsAgainst += statPack.team2.pts
  team2.ptsAgainst += statPack.team1.pts
  team1.pct = parseFloat((team1.matchesWon / team1.matches).toFixed(3))
  team2.pct = parseFloat((team2.matchesWon / team2.matches).toFixed(3))
  team1.avgPtsFor = parseFloat((team1.ptsFor / team1.games).toFixed(2))
  team2.avgPtsFor = parseFloat((team2.ptsFor / team2.games).toFixed(2))
  team1.avgPtsAgainst = parseFloat((team1.ptsAgainst / team1.games).toFixed(2))
  team2.avgPtsAgainst = parseFloat((team2.ptsAgainst / team2.games).toFixed(2))
  team1.save (err, updatedTeam1) ->
    if err
      cb err, null
    team2.save (err, updatedTeam2) ->
      if err
        cb err, null
      else
        cb null, [
          updatedTeam1
          updatedTeam2
        ], winnerID
      return
    return
  return

module.exports =
  create: (req, res) ->
    team = createNewTeam(req.body.players)
    team.save (err) ->
      if err
        res.send err
      res.json message: 'Team created!'
      return
    return
  findAll: (req, res) ->
    Team.find (err, teams) ->
      if err
        res.send err
      res.json teams
      return
    return
  find: (req, res) ->
    Team.findById req.params.teamId, (err, team) ->
      if err
        res.send err
      res.json team
      return
    return
  update: (req, res) ->
    Team.findById req.params.teamId, (err, team) ->
      if err
        res.send err
      newVals = req.body
      for prop of newVals
        if newVals.hasOwnProperty(prop)
          if team[prop] != undefined
            team[prop] = newVals[prop]
      team.save (err) ->
        if err
          res.send err
        res.json message: 'Team updated!'
        return
      return
    return
  getOrCreate: (info, cb) ->
    Team.find(players: $all: info).populate('players').exec (err, team) ->
      if err
        cb err, null
      if team and team.length > 0
        # Found a team
        cb null, team[0]
      else
        # Need to create a team
        createNewTeam info, (err, newTeam) ->
          newTeam.save (err, createdTeam) ->
            if err
              cb err, null
            Team.findById(createdTeam._id).populate('players').exec (err, finalTeam) ->
              if err
                cb err, null
              cb null, finalTeam
              return
            return
          return
      return
    return
  updateTeamStats: (match, statPack, cb) ->
    args = arguments
    Team.find { _id: $in: [
      match.team1
      match.team2
    ] }, (err, teams) ->
      if err
        cb err
      else if args.length == 2
        updateStatsFromMatch match, teams, cb
      else
        updateUsingStatPack match, teams, statPack, cb
      return
    return