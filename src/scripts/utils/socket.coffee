io = require 'socket.io/node_modules/socket.io-client'
ServerActionCreator = require 'scripts/actions/server-action-creator'
conf= require './config'

socket = io(window.location.hostname.concat ':', conf.port)

socket.on 'connect', ->
  console.info 'Socket connected!'

  socket.on 'matchUpdate', (data) ->
    ServerActionCreator.receiveScoreUpdate data

  socket.on 'disconnect', ->
    console.warn 'Socket disconnected.'