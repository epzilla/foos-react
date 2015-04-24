elo = require('elo-rank')()

module.exports =

  getRandomNum: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  getSweepWinValue: (margin) ->
    # Calculate what factor to use in calculating the ratings
    # change after a sweep victory, based on margin of victory
    # MOV >= 5 means 1 full point
    # MOV < 5 will yield somewhere between 0.8 and 1
    if margin > 5
      1
    else
      0.8 + ((factor / 5) * 0.2)

  getTwoThirdsWinValue: (margin) ->
    # Calculate what factor to use in calculating the ratings
    # change after a victory where a team won 2/3 games.
    # MOV >= 5 yields 0.75
    # MOV < 5 (including negative) will yield somewhere
    # between 0.55 and 0.75
    if margin < 0
      0.55
    else if margin >= 5
      0.75
    else
      0.55 + ((margin / 5) * 0.2)

  getSweepLossValue: (margin) ->
    # Calculate what factor to use in calculating the ratings
    # change after a loss where a team got swept.
    # MOV >= 5 yields 0
    # MOV < 5 (including negative) will yield somewhere
    # between 0 and 0.2
    if margin >= 5
      0
    else
      0.2 - ((margin / 5) * 0.2)

  getTwoThirdsLossValue: (margin) ->
    # Calculate what factor to use in calculating the ratings
    # change after a loss where a team lost 2/3 games.
    # MOV >= 5 yields 0.25
    # MOV < 5 (including negative, meaning the losing team
    # actually scored more points than the winning team)
    # will yield somewhere between 0.25 and 0.45
    if margin < 0
      0.45
    else if margin >= 5
      0.25
    else
      0.45 - ((margin / 5) * 0.2)

  getPrediction: (team1, team2) ->
    expected = elo.getExpected team1.rating, team2.rating

    console.log 'Team 1 expected result is : ' + expected
    if expected >= 0.55
      winner = team1
      loser = team2
      action = 'sweep'
    else if expected < 0.55 and expected >= 0.52
      winner = team1
      loser = team2
      action = 'win 2 of 3 against'
    else if expected > 0.48 and expected < 0.52
      winner = null
      loser = null
      action = 'tie'
    else if expected > 0.45 and expected <= 0.48
      winner = team2
      loser = team1
      action = 'win 2 of 3 against'
    else
      winner = team2
      loser = team1
      action = 'sweep'

    {
      winner: winner
      loser: loser
      action: action
    }