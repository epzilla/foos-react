React = require 'react'
PlayerStore = require 'scripts/stores/player-store'
Actions = require 'scripts/actions/view-action-creator'

getPlayerInfo = (id) ->
  {
    player: PlayerStore.getPlayerInfo(id)
  }

module.exports = React.createClass
  _onChange: ->
    @setState getPlayerInfo(@props.params.playerID)

  getInitialState: ->
    getPlayerInfo(@props.params.playerID)

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    Actions.getPlayers()

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    @_onChange

  render: ->
    player = @state.player
    if player
      matchRecord = player.matchesWon + '-' + player.matchesLost
      gameRecord = player.gamesWon + '-' + player.gamesLost
      <section className="container">
        <div className="row pad-bottom-1em flex-container-small-screen">
          <div className="col-xs-4 text-right">
            <img src={player.img} />
          </div>
          <div className="col-xs-8 player-headers">
            <h1>{player.name}</h1>
          </div>
        </div>
        <div className="row text-center">
          <h3>Match Record: {matchRecord}</h3>
        </div>
        <div className="row text-center">
          <h3>Game Record: {gameRecord}</h3>
        </div>
        <div className="row text-center">
          <h3>Avg. Score: {player.avgPtsFor} - {player.avgPtsAgainst}</h3>
        </div>
      </section>
    else
      <section className="container"></section>