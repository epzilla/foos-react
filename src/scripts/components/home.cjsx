React = require 'react/addons'
Router = require 'react-router'
{Link, Navigation} = Router
MatchStore = require 'scripts/stores/match-store'
PlayerStore = require 'scripts/stores/player-store'
Recents = require 'scripts/components/recents'
SeriesHistory = require 'scripts/components/series'
Scoreboard = require 'scripts/components/scoreboard'
API = require 'scripts/utils/api'

getMatchState = ->
  {
    currentMatch: MatchStore.getCurrentMatch()
    recentMatches: MatchStore.getRecentMatches()
    seriesHistory: MatchStore.getSeriesHistory()
    winner: MatchStore.getWinner()
    newPlayerInfo: PlayerStore.getNewPlayerInfo()
  }

Home = React.createClass
  mixins: [Navigation]

  getInitialState: ->
    getMatchState()

  componentDidMount:  ->
    MatchStore.addChangeListener @_onChange
    PlayerStore.addChangeListener @_onChange

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange
    PlayerStore.removeChangeListener @_onChange

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
    </div>

  _onChange: ->
    @setState getMatchState()
    if @state.newPlayerInfo
      @transitionTo '/playerRegistration'

module.exports = Home