io = require 'socket.io/node_modules/socket.io-client'
ServerActionCreator = require 'scripts/actions/server-action-creator'
conf = require '../../../conf/config'

addr = window.location.hostname + ':' + conf.PORT
socket = io(addr)
online = true

socket.on 'connect', ->
  console.info 'Socket connected!'
  if !online
    online = true
    ServerActionCreator.sendAlert(
      type: 'success'
      persistent: false
      text: 'And we\'re back!')

  socket.on 'playerRegistered', (data) ->
    ServerActionCreator.receiveRegisteredPlayer data

  socket.on 'matchUpdate', (data) ->
    ServerActionCreator.receiveScoreUpdate data

  socket.on 'matchError', (data) ->
    ServerActionCreator.receiveMatchError data

  socket.on 'nfcError', (data) ->
    ServerActionCreator.receiveNFCError data

  socket.on 'playerNames', (data) ->
    ServerActionCreator.receivePlayerNames data

  socket.on 'prediction', (data) ->
    ServerActionCreator.receivePrediction data

  socket.on 'announceHeckle', (data) ->
    ServerActionCreator.heckle data

  socket.on 'disconnect', ->
    console.warn 'Socket disconnected.'
    online = false
    ServerActionCreator.sendAlert(
      type: 'warn'
      persistent: true
      text: 'Bummer! Looks like you\'re offline. You won\'t receive score updates until your connection is restored.')

module.exports = socket