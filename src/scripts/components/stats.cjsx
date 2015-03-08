React = require 'react/addons'
Table = require('reactable').Table
Actions = require 'scripts/actions/view-action-creator'
PlayerStore = require 'scripts/stores/player-store'
TeamStore = require 'scripts/stores/team-store'
_ = require 'lodash'

module.exports = React.createClass
  _getTeamsAndPlayers: ->
    players = PlayerStore.getPlayers()
    teams = TeamStore.getTeams()
    formattedPlayers = []
    formattedTeams = []

    _.forEach players, (player) ->
      formattedMatchPct = if player.pct < 1 then ('.' + player.pct.toPrecision(4).toString().split('.')[1]) else '1.000'
      formattedGamePct = if player.gamesWon then (player.gamesWon / player.games).toPrecision(3) else '.000'
      if formattedGamePct is '1.00'
        formattedGamePct = '1.000'
      formattedPlayers.push
        'Player': player.name
        'Match Record': player.matchesWon + '-' + player.matchesLost
        'Match Win Pct.': formattedMatchPct
        'Game Record': player.gamesWon + '-' + player.gamesLost
        'Game win Pct.': formattedGamePct
        'Avg. Score': player.avgPtsFor + '-' + player.avgPtsAgainst

    {
      players: formattedPlayers
    }

  _onChange: ->
    @setState @_getTeamsAndPlayers()

  getInitialState: ->
    @_getTeamsAndPlayers()

  componentDidMount: ->
    PlayerStore.addChangeListener this._onChange
    TeamStore.addChangeListener this._onChange
    Actions.getTeams()
    Actions.getPlayers()
    return

  render: ->
    <section className="row">
      <div className="col-md-12">
        <Table className="table table-hover table-responsive text-center table-bordered"
          data={@state.players}
          sortable={true}
        />
      </div>
    </section>