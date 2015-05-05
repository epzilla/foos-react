Random = require './random'
ls = require './local-storage'
_prediction = undefined

iOS = /(iPad|iPhone|iPod)/g.test( navigator.userAgent )

announce = (words) ->
  msg = new SpeechSynthesisUtterance words
  if iOS
    msg.rate = 0.3
  window.speechSynthesis.speak msg

getRandomPlayer = (playerNames) ->
  if playerNames and playerNames.length > 0
    pNum = Random.getRandomNum(0, playerNames.length - 1)
    playerNames[pNum]

getPredictionPhrase = (prediction) ->
  w = undefined
  l = undefined

  if prediction.winner
    w = prediction.winner.title
    l = prediction.loser.title

  sweepPhrases = [
    'Oh boy! I don\'t like the looks of this! The predict-o-matic ' + 'says we\'re in for a blowout! I expect to see ' + w + ' take all 3 games vs. ' + l,
    'Good luck, ' + l + '. Looks like you may need it!',
    'I have to admit, I really like ' + w +  '\'s chances in this one.'
  ]

  tiePhrases = [
    'We could be in for a treat here. This one looks too close to call!',
    'I just can\'t quite decide on who I think will win this. Let\'s find out!',
    'I can\'t wait to see who wins. I sure can\'t predict this one.'
  ]

  twoOfThreePhrases = [
    'By the way, our computer predicts that ' + w + ' will ' + prediction.action + ' ' + l,
    'Just to add some fuel to the fire, the experts expect ' + w + ' to ' + prediction.action + ' ' + l,
    'Looks like there may be a slight edge in this one. According to my rating system, ' + 'I look for ' + w + ' to ' + prediction.action + ' ' + l
  ]

  if prediction.action is 'sweep'
    phraseNum = Random.getRandomNum(0, sweepPhrases.length - 1)
    sweepPhrases[phraseNum]
  else if prediction.action is 'tie'
    phraseNum = Random.getRandomNum(0, tiePhrases.length - 1)
    tiePhrases[phraseNum]
  else
    phraseNum = Random.getRandomNum(0, twoOfThreePhrases.length - 1)
    twoOfThreePhrases[phraseNum]

getWelcomePhrase = (name) ->
  phrases = [
    'Welcome, ' + name + '.',
    name + ' has entered the game.',
    'Hey there, ' + name + '.',
    'What up, ' + name + '?',
    name + ' is in the building! Holla!',
    'What has two thumbs and loves foosball?... ' + name,
    'Good to see you, ' + name + '!'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getMatchInstructions = (match) ->
  black = match.team1.title
  yellow = match.team2.title
  phrases = [
    black + ', take the black bars. ' + yellow + ', go ahead and grab the yellow rods.',
    black + ', you\'ll be playing black for the first game. ' + yellow + ', you\'ve got yellow.',
    black + ', make like Jon Snow and take the black. ' + yellow + ', make like Coldplay and rock that yellow.',
    black + ', they say once you go black... Um, nevermind. Anyway... ' + yellow + ', just go ahead and take yellow.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getStartMessage = ->
  phrases = [
    'OK, let\'s get ready to rumble!',
    'Alright, let\'s get it crack-a-lackin\'.',
    'Looks like it\'s that time!',
    'Are you ready for some foosball?!'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getSwitchMessage = ->
  phrases = [
    'OK, time to switch it up!',
    'And that\'s a switch!',
    'Looks like it\'s time to switch!',
    'Hey! Don\'t forget to switch!',
    'That five went by fast! Time for a switch already?'
    'That\'s five! Switch it up!'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getPlayerHeckleMessage = (player) ->
  phrases = [
    'Hey ' + player + ', nice shot! Does your husband play?',
    player + ', yours is less of a snake shot, more of a dead worm shot.',
    'Oh no, is ' + player + ' playing? I was hoping to see some good foosball for once. Oh well...',
    'So ' + player + ', if you had to describe your foosball skills on a scale from ' +
      'embarrassing to complete dumpster fire, what would you go with?',
    'I once saw ' + player + ' lose a game by foosing himself 10 times in a row... True story.',
    'Hey ' + player + ', do you come here often? Because based on your playing, I\'m guessing no.',
    'Haha, holy crap ' + player + ', what are you even doing? Just stop. Please.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getGenericHeckleMessage = (player) ->
  phrases = [
    'Man, this is some world class foosball here... In case you can\'t tell, that was sarcasm.',
    'Your mom!',
    'Back to work, slackers!',
    'What am I watching here? To call this foosball seems like an insult to the sport.',
    'Hey have you guys heard about goals? You should try scoring them sometime.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

module.exports =
  announcePlayer: (name) ->
    if window.speechSynthesis
      firstName = name.split(' ')[0]
      words = getWelcomePhrase firstName
      announce words

  giveNewMatchInstructions: (match, nextSound) ->
    sound = document.querySelector 'audio'
    sound.src = nextSound

    if window.speechSynthesis
      startMsg = getStartMessage()
      ins = getMatchInstructions match
      totalMsg = startMsg + ' ' + ins

      msg = new SpeechSynthesisUtterance totalMsg
      msg.rate = 0.3
      msg.onend = (e) ->
        if _prediction
          pred = new SpeechSynthesisUtterance _prediction
          pred.onend = (e) ->
            sound.play()

          window.speechSynthesis.speak pred
        else
          sound.play()

      window.speechSynthesis.speak msg
    else
      window.setTimeout(->
        sound.play()
      , 1000)

  announceSwitch: ->
    if window.speechSynthesis
      words = getSwitchMessage()
      announce words

  unrecognizedTag: ->
    if window.speechSynthesis
      words = 'I don\'t recognize that tag. Tell me who you are, and I\'ll get you set up to play.'
      announce words

  queuePrediction: (prediction) ->
    _prediction = getPredictionPhrase prediction

  heckle: (data) ->
    if window.speechSynthesis
      if data.player
        words = getPlayerHeckleMessage(data.player)
      else
        words = getGenericHeckleMessage()

      announce words
