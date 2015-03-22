io = require 'socket.io/node_modules/socket.io-client'
ServerActionCreator = require 'scripts/actions/server-action-creator'
# ViewActionCreator = require 'scripts/actions/view-action-creator'
conf = require './config'

socket = io(window.location.hostname.concat ':', conf.port)
console.log ServerActionCreator
online = true

socket.on 'connect', ->
  console.info 'Socket connected!'
  if !online
    online = true
    ServerActionCreator.sendAlert(
      type: 'success'
      persistent: false
      text: 'And we\'re back!')

  socket.on 'matchUpdate', (data) ->
    ServerActionCreator.receiveScoreUpdate data

  socket.on 'disconnect', ->
    console.warn 'Socket disconnected.'
    online = false
    ServerActionCreator.sendAlert(
      type: 'warn'
      persistent: true
      text: 'You\'re offline. But no worries, your score will continue to be kept and published when you reconnect')

module.exports = socket