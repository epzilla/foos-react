Random = require './random'

getWelcomePhrase = (name) ->
  phrases = [
    'Welcome, ' + name + '.',
    name + ' has entered the game.',
    'Hey there, ' + name + '.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getMatchInstructions = (match) ->
  black = match.team1.title
  yellow = match.team2.title
  phrases = [
    black + ', take the black bars. ' + yellow + ', go ahead and grab the yellow rods.',
    black + ', you\'ll be playing black for the first game. ' + yellow + ', you\'ve got yellow.',
    black + ', make like Jon Snow and take the black. ' + yellow + ', make like Coldplay and rock that yellow.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getStartMessage = ->
  phrases = [
    'OK, let\'s get ready to rumble!',
    'Alright, let\'s get it crack-a-lackin\'.',
    'Looks like it\'s that time!'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

module.exports =
  announcePlayer: (name) ->
    if window.speechSynthesis
      firstName = name.split(' ')[0]
      words = getWelcomePhrase firstName
      msg = new SpeechSynthesisUtterance words
      window.speechSynthesis.speak msg
      return

  giveNewMatchInstructions: (match, nextSound) ->
    sound = document.querySelector 'audio'
    sound.src = nextSound

    if window.speechSynthesis
      startMsg = getStartMessage()
      ins = getMatchInstructions match
      totalMsg = startMsg + ' ' + ins

      msg = new SpeechSynthesisUtterance totalMsg

      msg.onend = (e) ->
        sound.play()

      window.speechSynthesis.speak msg
      return
    else
      sound.play()