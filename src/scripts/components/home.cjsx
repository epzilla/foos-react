React = require 'react/addons'
Router = require 'react-router'
Rest = require 'scripts/utils/rest-service'
{Link} = Router
MatchStore = require 'scripts/stores/match-store'
Recents = require 'scripts/components/recents'
SeriesHistory = require 'scripts/components/series'
Scoreboard = require 'scripts/components/scoreboard'

getMatchState = ->
  {
    currentMatch: MatchStore.getCurrentMatch()
    recentMatches: MatchStore.getRecentMatches()
    seriesHistory: MatchStore.getSeriesHistory()
  }

Home = React.createClass
  getInitialState: ->
    getMatchState()

  componentDidMount:  ->
    MatchStore.addChangeListener this._onChange

  componentWillUnmount: ->
    MatchStore.removeChangeListener this._onChange

  render: ->
    match = this.state.currentMatch
    series = undefined

    if match and match.active
      jumbotron =
        <Scoreboard match={match}/>
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
      <Recents recents={this.state.recentMatches}/>
    </div>

  _onChange: ->
    @setState getMatchState()
    console.log this.state
    return

module.exports = Home