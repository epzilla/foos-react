fs = require 'fs'

SoundService = {}

getRandomNum = (max, min) ->
  Math.floor(Math.random() * (max - min) + min)

SoundService.getRandomSound = (req, res) ->
  folder = req.query['folder']
  fs.readdir('./dist' + folder, (err, files) ->
    if err
      res.status(500).send(err)
    if files
      count = files.length
      fileNum = getRandomNum(0, count)
      res.json({file: files[fileNum]})
  )

module.exports = SoundService