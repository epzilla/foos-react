window.$ = window.jQuery = require('jquery')
require('semantic-ui/dist/semantic')
React = require('react/addons')
Router = require('react-router')
Stats = require('./stats.cjsx')
qwest = require('qwest')
{Routes, Route, DefaultRoute, Link} = Router

Header = React.createClass
  render: ->
    <div className="ui blue inverted menu">
      <div className="ui page grid">
        <div className="column" style={"padding-bottom": 0}>
          <div className="title item">
            <b>SnappyFoos</b>
          </div>
          <Link className="item" to="home">
            Home
          </Link>
          <Link className="item" to="stats">
            About
          </Link>
        </div>
      </div>
    </div>

Home = React.createClass
  getInitialState: ->
    qwest.get '/api/teams'
      .then( (response) ->
        return {
          data: []
        }
      )

  componentDidMount:  ->
    qwest.get '/api/matches/current'
      .then( (response) =>
        if @isMounted()
          console.log response
          @setState(
            currentMatch: response
          )
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

Main = React.createClass
  render: ->
    <div>
      <Header/>
      <div className="ui padded grid">
        <@props.activeRouteHandler/>
      </div>
    </div>

NewMatch = React.createClass
  render: ->
    <div>
      <h2>Crikey!</h2>
    </div>

routes =
  <Routes location="history">
    <Route path="/" handler={Main}>
      <DefaultRoute name="home" handler={Home}/>
      <Route name="stats" handler={Stats}/>
      <Route name="newMatch" handler={NewMatch}/>
    </Route>
  </Routes>

$ -> React.renderComponent(routes, document.body)
