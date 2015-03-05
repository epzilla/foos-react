window.$ = window.jQuery = require 'jquery'
require 'bootstrap'
React = require 'react/addons'
Router = require 'react-router'
Stats = require 'scripts/components/stats'
Header = require 'scripts/components/header'
Home = require 'scripts/components/home'
NewMatch = require 'scripts/components/new-match'
API = require 'scripts/utils/api'
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

$ ->
  API.getHomeData()
  React.render(routes, document.body)
