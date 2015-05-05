React = require 'react/addons'
Router = require 'react-router'
{Link, Navigation, State} = Router
MatchStore = require 'scripts/stores/match-store'
PlayerStore = require 'scripts/stores/player-store'
Recents = require 'scripts/components/recents'
SeriesHistory = require 'scripts/components/series'
Scoreboard = require 'scripts/components/scoreboard'
ScoreCorrection = require 'scripts/components/score-correction'
HeckleBox = require 'scripts/components/heckle-box'
GamePad = require 'scripts/components/gamepad'
Announcer = require 'scripts/utils/announcer'
API = require 'scripts/utils/api'
conf = require '../../../conf/config'
cx = React.addons.classSet

heckleBox = undefined
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

getMatchState = ->
  {
    currentMatch: MatchStore.getCurrentMatch()
    recentMatches: MatchStore.getRecentMatches()
    seriesHistory: MatchStore.getSeriesHistory()
    winner: MatchStore.getWinner()
    newPlayerInfo: PlayerStore.getNewPlayerInfo()
    playerNames: PlayerStore.getPlayerNames()
    unrecognizedNFC: PlayerStore.getUnrecognizedNFC()
  }

Home = React.createClass
  mixins: [Navigation, State]

  secretCode: '38,38,40,40,37,39,37,39,66,65'
  pressedKeys: []

  _keyUpHandler: (e) ->
    key = e.keyCode
    @pressedKeys.push key

    if @pressedKeys.toString().indexOf(@secretCode) >= 0
      @pressedKeys = []
      heckleBox = document.querySelector '.heckle-box'
      sound = document.querySelector 'audio'
      controller = document.getElementById 'controller'
      sound.src = '/sounds/secret/reveal.wav'
      sound.play()
      heckleBox.classList.add 'revealed'
      controller.classList.remove 'revealed'
    else if @pressedKeys.length > 100
      @pressedKeys = []

  getInitialState: ->
    getMatchState()

  componentDidMount:  ->
    MatchStore.addChangeListener @_onChange
    PlayerStore.addChangeListener @_onChange
    document.addEventListener 'keyup', @_keyUpHandler

    if 'ontouchstart' of window
      document.body.addEventListener 'touchstart', sndInit
      gamepad = document.querySelector '.gamepad-icon'
      if gamepad
        gamepad.style.display = 'block'

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange
    PlayerStore.removeChangeListener @_onChange
    document.removeEventListener 'keyup', @_keyUpHandler

  render: ->
    match = if @state.currentMatch and @state.currentMatch.active then @state.currentMatch else null
    series = undefined
    scoreCorrector = undefined
    code = @getQuery().code
    teamMap = conf.TEAM_MAP
    blackTitle = ''
    yellowTitle = ''

    if match and match.gameNum
      if match.gameNum is 2
        blackTitle = match[teamMap.game2.black].title
        yellowTitle = match[teamMap.game2.yellow].title
      else
        blackTitle = match[teamMap.game1.black].title
        yellowTitle = match[teamMap.game1.yellow].title

      if code
        scoreCorrector =
          <div>
            <ScoreCorrection blackTitle={blackTitle} yellowTitle={yellowTitle} code={code} />
            <hr />
          </div>

    if match
      jumbotron =
        <Scoreboard match={match} winner={@state.winner}/>
      series =
        <div>
          <SeriesHistory series={@state.seriesHistory}/>
          <hr />
        </div>
    else
      jumbotron =
        <div className="row">
          <div className="col-md-12">
            <div className="jumbotron text-center">
              <h1>Good news, everyone!</h1>
              <p>The table is open.</p>
              <img className="img img-responsive margin-centered" src="images/professor.jpg" />
              <div className="text-center pad-top-1em">
                <Link className="btn btn-lg btn-primary" to="newMatch">
                  Start New Match
                </Link>
              </div>
            </div>
          </div>
        </div>

    <div>
      <section>{jumbotron}</section>
      <hr />
      {scoreCorrector}
      {series}
      <Recents recents={@state.recentMatches}/>
      <GamePad onChange={@_keyUpHandler}/>
      <HeckleBox players={@state.playerNames} />
    </div>

  _onChange: ->
    @setState getMatchState()
    document.removeEventListener 'keyup', @_keyUpHandler
    document.addEventListener 'keyup', @_keyUpHandler
    if @state.newPlayerInfo
      @transitionTo '/playerRegistration'
    else if @state.unrecognizedNFC
      @transitionTo '/nfcRegistration'

module.exports = Home