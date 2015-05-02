React = require 'react'
PlayerStore = require 'scripts/stores/player-store'
Actions = require 'scripts/actions/view-action-creator'
Router = require 'react-router'
{Link, State} = Router

getPlayerInfo = (id) ->
  {
    player: PlayerStore.getPlayerInfo(id)
  }

module.exports = React.createClass
  mixins: [ State ]

  _onChange: ->
    @setState getPlayerInfo(@getParams().playerID)

  getInitialState: ->
    getPlayerInfo(@getParams().playerID)

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    Actions.getPlayers()

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    @_onChange()

  render: ->
    player = @state.player
    <h1>{player.name}</h1>