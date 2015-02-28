React = require('react/addons')
Router = require('react-router')
Rest = require('scripts/rest')
{Link} = Router

module.exports = React.createClass
  getInitialState: ->
    currentMatch: []
    recentMatches: []

  componentDidMount:  ->
    Promise.all [Rest.get('/api/matches/current'), Rest.get('/api/matches/recent')]
      .then( (response) =>
        if @isMounted()
          @setState(
            currentMatch: response[0]
            recentMatches: response[1]
          )
        console.log _this.state
        return
      )

  render: ->
    match = this.state.currentMatch
    
    if match and match.active
      <div className="row">
        <div className="column">
          <div className="ui segment">
            <h1 className="ui huge header center aligned">Bad News, Everyone!</h1>
            <h3 className="ui huge header center aligned">The table is taken.</h3>
            <img src="images/professor.jpg" className="ui image large centered" />
            <div className="ui align-center padding-top-1em">
              <Link className="ui large blue button center aligned" to="newMatch">
                Start New Match
              </Link>
            </div>
            <div className="ui clearing section divider"></div>
          </div>
        </div>
      </div>
    else
      <div className="row">
        <div className="column">
          <div className="ui segment">
            <h1 className="ui huge header center aligned">Good News, Everyone!</h1>
            <h3 className="ui huge header center aligned">The table is open.</h3>
            <img src="images/professor.jpg" className="ui image large centered" />
            <div className="ui align-center padding-top-1em">
              <Link className="ui large blue button center aligned" to="newMatch">
                Start New Match
              </Link>
            </div>
            <div className="ui clearing section divider"></div>
          </div>
        </div>
      </div>