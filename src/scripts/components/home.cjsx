React = require 'react/addons'
Router = require 'react-router'
{Link} = Router
MatchStore = require 'scripts/stores/match-store'
Recents = require 'scripts/components/recents'
SeriesHistory = require 'scripts/components/series'
Scoreboard = require 'scripts/components/scoreboard'
API = require 'scripts/utils/api'

getMatchState = ->
  {
    currentMatch: MatchStore.getCurrentMatch()
    recentMatches: MatchStore.getRecentMatches()
    seriesHistory: MatchStore.getSeriesHistory()
    sound: MatchStore.getSound()
  }

Home = React.createClass
  getInitialState: ->
    getMatchState()

  componentDidMount:  ->
    # btn = document.querySelector '#audioBtn'
    # sound = document.querySelector 'audio'
    # btn.addEventListener 'click', (e) ->
    #   API.getSound('/sounds/goal').then( (res) ->
    #     sound.src = '/sounds/goal/' + res.file
    #     sound.play()
    #   ).catch( (err) ->
    #     console.error err
    #   )
    #   return
    MatchStore.addChangeListener @_onChange

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange

  render: ->
    match = if @state.currentMatch and @state.currentMatch.active then @state.currentMatch else null
    series = undefined

    if match
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
      <button id="audioBtn">Play Sound</button>
      {series}
      <Recents recents={@state.recentMatches}/>
    </div>

  _onChange: ->
    @setState getMatchState()
    sound = document.querySelector 'audio'
    sound.src = @state.sound
    sound.play()

module.exports = Home