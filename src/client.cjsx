window.$ = window.jQuery = require 'jquery'
require 'bootstrap'
React = require 'react/addons'
Router = require 'react-router'
Stats = require 'scripts/components/stats'
Header = require 'scripts/components/header'
Home = require 'scripts/components/home'
Alerts = require 'scripts/components/alerts'
NewMatch = require 'scripts/components/new-match'
PlayerRegistration = require 'scripts/components/player-registration'
NFCRegistration = require 'scripts/components/nfc-registration'
API = require 'scripts/utils/api'
{Routes, Route, DefaultRoute, Link} = Router

Main = React.createClass
  render: ->
    <div>
      <Header />
      <div className="container">
        <@props.activeRouteHandler/>
      </div>
      <Alerts />
      <audio src="/sounds/goal/TOUCHDOWN.mp3" preload="auto"/>
      <div id="init"></div>
    </div>

routes =
  <Routes location="history">
    <Route path="/" handler={Main}>
      <DefaultRoute name="home" handler={Home}/>
      <Route name="stats" handler={Stats}/>
      <Route name="newMatch" handler={NewMatch}/>
      <Route name="playerRegistration" handler={PlayerRegistration}/>
      <Route name="nfcRegistration" handler={NFCRegistration}/>
    </Route>
  </Routes>

$ ->
  API.getHomeData()
  API.getPlayers()
  React.render(routes, document.body)
  sound = document.querySelector 'audio'

  sndInit = ->
    sound = document.querySelector 'audio'
    sound.play()
    sound.pause()
    document.getElementById('init').style.display = 'none'

  `if ('ontouchstart' in window) {
    document.getElementById('init').addEventListener('touchstart', sndInit);
  } else {
    document.getElementById('init').style.display = 'none'
  }`
  return
