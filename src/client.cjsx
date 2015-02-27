window.$ = window.jQuery = require('jquery')
require('semantic-ui/dist/semantic')
React = require('react/addons')
Router = require('react-router')
Stats = require('./stats.cjsx')
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
  render: ->
    <div className="row">
      <div className="column">
        <div className="ui segment">
          <h1 className="ui huge header center aligned">Good News, Everyone!</h1>
          <h3 className="ui huge header center aligned">The table is open.</h3>
          <img src="images/professor.jpg" className="ui image large centered" />
          <div className="ui align-center padding-top-1em">
            <button className="ui large blue button center aligned">Start New Match</button>
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

routes =
  <Routes location="history">
    <Route path="/" handler={Main}>
      <DefaultRoute name="home" handler={Home}/>
      <Route name="stats" handler={Stats}/>
    </Route>
  </Routes>

$ -> React.renderComponent(routes, document.body)
