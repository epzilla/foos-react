fs = require 'fs'
Utils = require './utils'
conf = require '../../conf/config'
env = conf.ENVIRONMENT
SoundService = {}

relPath = if env is 'prod' or env is 'production' then '' else './.tmp/'

SoundService.getRandomGoalSound = (callback) ->
  fs.readdir(relPath + 'sounds/goal', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/goal/' + files[fileNum])
      return
  )
  return

SoundService.getRandomGamePointSound = (callback) ->
  fs.readdir(relPath + '/sounds/gamePoint', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/gamePoint/' + files[fileNum])
      return
  )
  return

SoundService.getRandomTrashTalkSound = (callback) ->
  fs.readdir(relPath + '/sounds/trashTalk', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/trashTalk/' + files[fileNum])
      return
  )
  return

SoundService.getRandomSquirrelSound = (callback) ->
  fs.readdir(relPath + '/sounds/squirrel', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/squirrel/' + files[fileNum])
      return
  )
  return

SoundService.getRandomStartGameSound = (callback) ->
  fs.readdir(relPath + '/sounds/startGame', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/startGame/' + files[fileNum])
      return
  )
  return

SoundService.getRandomEndGameSound = (callback) ->
  fs.readdir('./sounds/endGame', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count - 1)
      callback(null, '/sounds/endGame/' + files[fileNum])
      return
  )
  return

SoundService.getRandomWelcomeGameSound = (callback) ->
  fs.readdir(relPath + '/sounds/welcome', (err, files) ->
    if err
      callback(err)
    if files
      count = files.length
      fileNum = Utils.getRandomNum(0, count)
      callback(null, '/sounds/welcome/' + files[fileNum])
      return
  )
  return

module.exports = SoundService