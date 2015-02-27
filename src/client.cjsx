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
    <div className="column">
      <div className="ui segment">
        <h1 className="ui header">
          <span>Get to work!</span>
          <div className="sub header">
            Make sure to check out README.md for development notes.
          </div>
        </h1>
      </div>
    </div>

About = React.createClass
  render: ->
    <div className="column">
      <div className="ui segment">
        <h4 className="ui black header">This is the about page.</h4>
      </div>
    </div>

Main = React.createClass
  render: ->
    <div>
      <Header/>
      <div className="ui page grid">
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
