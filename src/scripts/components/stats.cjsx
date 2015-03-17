React = require 'react/addons'
Table = require('reactable').Table
Actions = require 'scripts/actions/view-action-creator'
PlayerStore = require 'scripts/stores/player-store'
TeamStore = require 'scripts/stores/team-store'
_ = require 'lodash'

TableView = React.createClass
  render: ->
    <section className="row">
      <div className="col-md-12">
        <Table className="table table-hover table-responsive text-center table-bordered"
          data={@props.data}
          sortable={[
            'Team',
            'Player',
            {
              column: 'Match Record',
              sortFunction: (a, b) ->
                aParts = a.split '-'
                bParts = b.split '-'
                aPct = aParts[0] / (aParts[0] + aParts[1])
                bPct = bParts[0] / (bParts[0] + bParts[1])
                if aPct is bPct
                  if aParts[0] is bParts[0]
                    aParts[1] < bParts[1]
                  else
                    aParts[0] > bParts[0]
                else
                  aPct > bPct
            },
            {
              column: 'Game Record',
              sortFunction: (a, b) ->
                aParts = a.split '-'
                bParts = b.split '-'
                aPct = aParts[0] / (aParts[0] + aParts[1])
                bPct = bParts[0] / (bParts[0] + bParts[1])
                if aPct is bPct
                  if aParts[0] is bParts[0]
                    aParts[1] > bParts[1]
                  else
                    aParts[0] > bParts[0]
                else
                  aPct > bPct
            },
            {
              column: 'Avg. Score',
              sortFunction: (a, b) ->
                aParts = a.split '-'
                bParts = b.split '-'
                aMargin = aParts[0] - aParts[1]
                bMargin = bParts[0] - bParts[1]
                aMargin > bMargin
            },
          ]}
          defaultSort={@props.sorting}
        />
      </div>
    </section>

module.exports = React.createClass
  _getTeamsAndPlayers: ->
    players = PlayerStore.getPlayers()
    teams = TeamStore.getTeams()
    formattedPlayers = []
    formattedTeams = []

    _.forEach players, (player) ->
      if player.matches isnt 0
        # We want to filter out any player who hasn't actually played a match yet
        formattedMatchPct = if player.pct < 1 then ('.' + player.pct.toPrecision(4).toString().split('.')[1]) else '1.000'
        formattedGamePct = if player.gamesWon then (player.gamesWon / player.games).toPrecision(3) else '.000'
        if formattedGamePct is '1.00'
          formattedGamePct = '1.000'
        formattedPlayers.push
          'Player': player.name
          'Match Record': player.matchesWon + '-' + player.matchesLost
          'Game Record': player.gamesWon + '-' + player.gamesLost
          'Avg. Score': player.avgPtsFor + '-' + player.avgPtsAgainst

    _.forEach teams, (team) ->
      if team.matches isnt 0
        # We want to filter out any team who hasn't actually played a match yet
        formattedMatchPct = if team.pct < 1 then ('.' + team.pct.toPrecision(4).toString().split('.')[1]) else '1.000'
        formattedGamePct = if team.gamesWon then (team.gamesWon / team.games).toPrecision(3) else '.000'
        if formattedGamePct is '1.00'
          formattedGamePct = '1.000'
        formattedTeams.push
          'Team': team.title
          'Match Record': team.matchesWon + '-' + team.matchesLost
          'Game Record': team.gamesWon + '-' + team.gamesLost
          'Avg. Score': team.avgPtsFor + '-' + team.avgPtsAgainst

    {
      players: formattedPlayers
      teams: formattedTeams
      selectedTab: 'players'
    }

  _onChange: ->
    @setState @_getTeamsAndPlayers()

  getInitialState: ->
    @_getTeamsAndPlayers()

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    TeamStore.addChangeListener @_onChange
    Actions.getTeams()
    Actions.getPlayers()
    return

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange
    TeamStore.removeChangeListener @_onChange

  handleChange: (e) ->
    @state.selectedTab = e.target.value
    @forceUpdate()

  render: ->
    table = undefined
    if @state.selectedTab is 'players'
      table = <TableView data={@state.players} sorting={{column: 'Match Record', direction: 'desc' }}/>
    else
      table = <TableView data={@state.teams} sorting={{column: 'Match Record', direction: 'desc' }}/>

    <div>
      <section className="row">
        <section className="col-xs-12 text-center">
          <h1>Stats &amp; Records</h1>
        </section>
      </section>
      <section className="row">
        <section className="flex-container col-xs-12">
          <section className="flex-item width-200">
            <input id="by-player" type="radio" name="toggle"
              onChange={@handleChange}
              checked={@state.selectedTab is 'players'}
              value="players" />
            <label htmlFor="by-player" id="by-player-label">By Player</label>
            <input id="by-team" type="radio" name="toggle"
              onChange={@handleChange}
              checked={@state.selectedTab is 'teams'}
              value="teams"/>
            <label htmlFor="by-team" id="by-team-label">By Team</label>
          </section>
        </section>
      </section>
      <section className="row main-table">
        {table}
      </section>
    </div>
