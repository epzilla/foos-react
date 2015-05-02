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
PlayerPic = require 'scripts/components/player-pic'
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
      <audio src="/sounds/secret/reveal.mp3" preload="auto"/>
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
    <Route name="playerpic" handler={PlayerPic} path="playerpic/:playerID"/>
  </Route>

$ ->
  API.getHomeData()
  API.getPlayers()
  Router.run(routes, HistoryLocation, (Handler) ->
    React.render(<Handler/>, document.body)
  )
  sound = document.querySelector 'audio'

  sndInit = ->
    sound = document.querySelector 'audio'
    sound.play()
    sound.pause()
    if window.speechSynthesis
      words = ' '
      msg = new SpeechSynthesisUtterance words
      window.speechSynthesis.speak msg
    document.body.removeEventListener('touchstart', sndInit)

  `if ('ontouchstart' in window) {
    document.body.addEventListener('touchstart', sndInit);
    var gamepad = document.querySelector('.gamepad-icon');
    if (gamepad) {
      gamepad.style.display = 'block';
    }
  }`
  return
