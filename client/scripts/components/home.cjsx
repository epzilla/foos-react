React = require 'react/addons'
Router = require 'react-router'
{Link, Navigation} = Router
MatchStore = require 'scripts/stores/match-store'
PlayerStore = require 'scripts/stores/player-store'
Recents = require 'scripts/components/recents'
SeriesHistory = require 'scripts/components/series'
Scoreboard = require 'scripts/components/scoreboard'
HeckleBox = require 'scripts/components/heckle-box'
GamePad = require 'scripts/components/gamepad'
Announcer = require 'scripts/utils/announcer'
API = require 'scripts/utils/api'

heckleBox = undefined

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
  mixins: [Navigation]

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

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange
    PlayerStore.removeChangeListener @_onChange
    document.removeEventListener 'keyup', @_keyUpHandler

  render: ->
    match = if @state.currentMatch and @state.currentMatch.active then @state.currentMatch else null
    series = undefined

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