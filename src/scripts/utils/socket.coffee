io = require 'socket.io/node_modules/socket.io-client'
conf= require './config'

socket = io(window.location.hostname.concat ':', conf.port)

socket.on 'connect', ->
  console.info 'Socket connected!'