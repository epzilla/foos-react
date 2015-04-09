Random = require './random'

getWelcomePhrase = (name) ->
  phrases = [
    'Welcome, ' + name + '.',
    name + ' has entered the game.',
    'Hey there, ' + name + '.'
  ]
  phraseNum = Random.getRandomNum(0, phrases.length - 1)
  phrases[phraseNum]

getMatchInstructions = (team, color) ->
  phrases = [
    team + ', take those ' + color + ' bars.',
    team + ', go ahead and grab the ' + color + ' rods.',
    team + ', you\'ll be playing ' + color + ' for the first game.'
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
    black = getMatchInstructions match.team1.title, 'black'
    yellow = getMatchInstructions match.team2.title, 'yellow'
    startMsg = getStartMessage()
    totalMsg = startMsg + ' ' + black + ' ' + yellow
    console.log black
    console.log yellow
    console.log totalMsg
    if window.speechSynthesis
      msg = new SpeechSynthesisUtterance totalMsg

      msg.onend = (e) ->
        sound = document.querySelector 'audio'
        sound.src = nextSound
        sound.play()

      window.speechSynthesis.speak msg
      return