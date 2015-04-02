fs = require 'fs'

SoundService = {}

getRandomNum = (max, min) ->
  Math.floor(Math.random() * (max - min) + min)

SoundService.getRandomGoalSound = (callback) ->
  fs.readdir('./dist/sounds/goal', (err, files) ->
    if err
      res.status(500).send(err)
    if files
      count = files.length
      fileNum = getRandomNum(0, count)
      callback(null, '/sounds/goal/' + files[fileNum])
      return
  )
  return

module.exports = SoundService