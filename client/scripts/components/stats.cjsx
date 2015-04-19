React = require 'react/addons'
Router = require 'react-router'
{Link, Navigation} = Router
Table = require('reactable').Table
Actions = require 'scripts/actions/view-action-creator'
PlayerStore = require 'scripts/stores/player-store'
TeamStore = require 'scripts/stores/team-store'
_ = require 'lodash'

recordSort = (a, b) ->
  aParts = a.split '-'
  bParts = b.split '-'
  aWins = parseInt(aParts[0])
  aLosses = parseInt(aParts[1])
  bWins = parseInt(bParts[0])
  bLosses = parseInt(bParts[1])
  aPct = aWins / (aWins + aLosses)
  bPct = bWins / (bWins + bLosses)
  if aPct is bPct
    if aWins is bWins
      bLosses - aLosses
    else
      aWins - bWins
  else
    aPct - bPct

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
              sortFunction: recordSort
            },
            {
              column: 'Game Record',
              sortFunction: recordSort
            },
            {
              column: 'Avg. Score (Margin)',
              sortFunction: (a, b) ->
                aParts = a.split '-'
                bParts = b.split '-'
                aFor = parseFloat(aParts[0])
                aSecondPart = aParts[1].split ' '
                aAgainst = parseFloat(aSecondPart[0])
                bFor = parseFloat(bParts[0])
                bSecondPart = bParts[1].split ' '
                bAgainst = parseFloat(bSecondPart[0])
                aMargin = aFor - aAgainst
                bMargin = bFor - bAgainst
                aMargin - bMargin
            },
          ]}
          defaultSort={@props.sorting}
        />
      </div>
    </section>

module.exports = React.createClass
  mixins: [Navigation]

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
        rawAvgMargin = (player.avgPtsFor - player.avgPtsAgainst).toFixed 1
        if rawAvgMargin > 0
          avgMargin = '(+' + rawAvgMargin + ')'
        else
          avgMargin = '(' + rawAvgMargin + ')'
        if formattedGamePct is '1.00'
          formattedGamePct = '1.000'
        formattedPlayers.push
          'Player': player.name
          'Match Record': player.matchesWon + '-' + player.matchesLost
          'Game Record': player.gamesWon + '-' + player.gamesLost
          'Avg. Score (Margin)': player.avgPtsFor + '-' + player.avgPtsAgainst + ' ' + avgMargin

    _.forEach teams, (team) ->
      if team.matches isnt 0
        # We want to filter out any team who hasn't actually played a match yet
        formattedMatchPct = if team.pct < 1 then ('.' + team.pct.toPrecision(4).toString().split('.')[1]) else '1.000'
        formattedGamePct = if team.gamesWon then (team.gamesWon / team.games).toPrecision(3) else '.000'
        rawAvgMargin = (team.avgPtsFor - team.avgPtsAgainst).toFixed 1
        if rawAvgMargin > 0
          avgMargin = '(+' + rawAvgMargin + ')'
        else
          avgMargin = '(' + rawAvgMargin + ')'
        if formattedGamePct is '1.00'
          formattedGamePct = '1.000'
        formattedTeams.push
          'Team': team.title
          'Match Record': team.matchesWon + '-' + team.matchesLost
          'Game Record': team.gamesWon + '-' + team.gamesLost
          'Avg. Score (Margin)': team.avgPtsFor + '-' + team.avgPtsAgainst + ' ' + avgMargin

    {
      players: formattedPlayers
      teams: formattedTeams
      newPlayerInfo: PlayerStore.getNewPlayerInfo()
      unrecognizedNFC: PlayerStore.getUnrecognizedNFC()
      selectedTab: 'players'
    }

  _onChange: ->
    @setState @_getTeamsAndPlayers()
    if @state.newPlayerInfo
      @transitionTo '/playerRegistration'
    else if @state.unrecognizedNFC
      @transitionTo '/nfcRegistration'

  getInitialState: ->
    @_getTeamsAndPlayers()

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    TeamStore.addChangeListener @_onChange
    Actions.getTeams()
    Actions.getPlayers()

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
