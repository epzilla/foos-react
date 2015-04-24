React = require 'react/addons'
Navigation = require('react-router').Navigation
PlayerStore = require 'scripts/stores/player-store'
MatchStore = require 'scripts/stores/match-store'

getPlayerInfo = ->
  {
    newPlayerInfo: PlayerStore.getNewPlayerInfo()
    playerNames: PlayerStore.getPlayerNames()
    didTimeout: PlayerStore.didTimeout()
    unrecognized: PlayerStore.getUnrecognizedNFC()
  }

module.exports = React.createClass
  mixins: [Navigation]

  _onPlayerChange: ->
    @setState getPlayerInfo()
    if @state.didTimeout
      @transitionTo '/'
    if @state.unrecognized
      @transitionTo '/nfcRegistration'

  _onMatchChange: ->
    match = MatchStore.getCurrentMatch()
    if match and match.active
      @transitionTo '/'

  componentDidMount: ->
    PlayerStore.addChangeListener @_onPlayerChange
    MatchStore.addChangeListener @_onMatchChange

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onPlayerChange
    MatchStore.removeChangeListener @_onMatchChange

  getInitialState: ->
    getPlayerInfo()

  render: ->
    newPlayer = @state.newPlayerInfo
    allPlayers = @state.playerNames
    playerList = []
    newPlayerHeader = ''

    if newPlayer
      newPlayerHeader = <h2 className="new-player pad-bottom-1em">{newPlayer}</h2>
    if allPlayers
      for player in allPlayers
        playerList.push(<li key={player._id}>{player}</li>)

    <section className="container">
      <div className="row">
        <div className="col-xs-12 text-center">
          <h1>Player Added:</h1>
          {newPlayerHeader}
          <h3>Players So Far:</h3>
          <ul className="player-list">
            {playerList}
          </ul>
        </div>
      </div>
    </section>