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
ScoreCorrection = require 'scripts/components/score-correction'
Notify = require 'scripts/components/notify'
Player = require 'scripts/components/player-profile'
Team = require 'scripts/components/team-profile'
API = require 'scripts/utils/api'
{Route, RouteHandler, DefaultRoute, Link, HistoryLocation} = Router

Main = React.createClass
  render: ->
    <div>
      <Header />
      <div className="container">
        <RouteHandler/>
      </div>
      <Alerts />
      <audio src="/sounds/goal/TOUCHDOWN.mp3" preload="auto"/>
      <div id="init"></div>
    </div>

routes =
  <Route path="/" handler={Main}>
    <DefaultRoute name="home" handler={Home}/>
    <Route name="stats" handler={Stats}/>
    <Route name="newMatch" handler={NewMatch}/>
    <Route name="playerRegistration" handler={PlayerRegistration}/>
    <Route name="nfcRegistration" handler={NFCRegistration}/>
    <Route name="scoreCorrection" handler={ScoreCorrection}/>
    <Route name="notify" handler={Notify}/>
    <Route name="players" handler={Player} path="players/:playerID"/>
    <Route name="teams" handler={Team} path="teams/:teamID"/>
  </Route>

$ ->
  API.getHomeData()
  API.getPlayers()
  Router.run(routes, HistoryLocation, (Handler) ->
    React.render(<Handler/>, document.body)
  )
  sound = document.querySelector 'audio'

  sndInit = ->
    document.getElementById('init').style.display = 'none'
    sound = document.querySelector 'audio'
    sound.play()
    sound.pause()
    if window.speechSynthesis
      words = ' '
      msg = new SpeechSynthesisUtterance words
      window.speechSynthesis.speak msg

  `if ('ontouchstart' in window) {
    document.getElementById('init').addEventListener('touchstart', sndInit);
    document.querySelector('.gamepad-icon').style.display = 'inline';
  } else {
    document.getElementById('init').style.display = 'none'
  }`
  return
