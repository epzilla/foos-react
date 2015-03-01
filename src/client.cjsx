window.$ = window.jQuery = require('jquery')
require('bootstrap')
React = require('react/addons')
Router = require('react-router')
Stats = require('jsx/stats')
Header = require('jsx/header')
Home = require('jsx/home')
NewMatch = require('jsx/new-match')
Rest = require('scripts/rest')
{Routes, Route, DefaultRoute, Link} = Router

Main = React.createClass
  render: ->
    <div>
      <Header/>
      <div className="container">
        <@props.activeRouteHandler/>
      </div>
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
