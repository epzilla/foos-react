React = require 'react/addons'
Router = require 'react-router'
Rest = require 'scripts/utils/rest-service'
{Link} = Router
MatchStore = require 'scripts/stores/match-store'

getMatchState = ->
  {
    currentMatch: MatchStore.getCurrentMatch()
    recentMatches: MatchStore.getRecentMatches()
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
    
    if match and match.active
      <div className="row">
        <div className="col-md-12">
          <div className="jumbotron text-center">
            <h1>Bad News, Everyone!</h1>
            <h3>The table is taken.</h3>
            <img className="img img-responsive margin-centered" src="images/professor.jpg" />
            <div className="text-center padding-top-1em">
              <Link className="btn btn-lg btn-primary" to="newMatch">
                Start New Match
              </Link>
            </div>
            <hr/>
          </div>
        </div>
      </div>
    else
      <div className="row">
        <div className="col-md-12">
          <div className="jumbotron text-center">
            <h1>Good News, Everyone!</h1>
            <h3>The table is open.</h3>
            <img className="img img-responsive margin-centered" src="images/professor.jpg" />
            <div className="text-center padding-top-1em">
              <Link className="btn btn-lg btn-primary" to="newMatch">
                Start New Match
              </Link>
            </div>
            <hr />
          </div>
        </div>
      </div>

  _onChange: ->
    @setState getMatchState()
    console.log this.state
    return

module.exports = Home