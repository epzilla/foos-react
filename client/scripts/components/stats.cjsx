React = require 'react/addons'
Reactable = require 'reactable'
Router = require 'react-router'
Table = Reactable.Table
Tr = Reactable.Tr
Td = Reactable.Td
{Link} = Router
Actions = require 'scripts/actions/view-action-creator'
PlayerStore = require 'scripts/stores/player-store'
TeamStore = require 'scripts/stores/team-store'
_ = require 'lodash'

recordSort = (record) ->
  recordParts = record.split '-'
  wins = parseInt recordParts[0]
  losses = parseInt recordParts[1]
  pct = wins / (wins + losses)
  if pct > 0 then pct else wins - losses

TableView = React.createClass
  render: ->
    data = @props.data
    which = @props.which
    rows = []
    data.forEach( (record) ->
      sortableMatchRecord = recordSort record.matchRecord
      sortableGameRecord = recordSort record.gameRecord
      avgMargin = parseInt record.avgMargin
      rating = parseInt record.rating
      if which is 'players'
        rows.push(
          <Tr>
            <Td column='Player'>
              <Link to="players" params={{playerID: record.id}}>
                {record.name}
              </Link>
            </Td>
            <Td column='Match Record' value={sortableMatchRecord} >{record.matchRecord}</Td>
            <Td column='Game Record' value={sortableGameRecord} >{record.gameRecord}</Td>
            <Td column='Avg. Score (Margin)' value={avgMargin} >{record.avg}</Td>
            <Td column='Rating' value={rating} >{record.rating}</Td>
          </Tr>
        )
      else
        rows.push(
          <Tr>
            <Td column='Team'>
              <Link to="teams" params={{teamID: record.id}}>
                {record.name}
              </Link>
            </Td>
            <Td column='Match Record' value={sortableMatchRecord} >{record.matchRecord}</Td>
            <Td column='Game Record' value={sortableGameRecord} >{record.gameRecord}</Td>
            <Td column='Avg. Score (Margin)' value={avgMargin} >{record.avg}</Td>
            <Td column='Rating' value={rating} >{record.rating}</Td>
          </Tr>
        )
    )

    <section className="row">
      <div className="col-md-12">
        <Table className="table table-hover table-responsive text-center table-bordered"
          defaultSort={@props.sorting}
          sortable={[
            'Teams',
            'Players',
            'Match Record',
            'Game Record',
            'Avg. Score (Margin)',
            'Rating'
          ]}
          >
        {rows}
        </Table>
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
        rawAvgMargin = (player.avgPtsFor - player.avgPtsAgainst).toFixed 1
        if rawAvgMargin > 0
          avgMargin = '(+' + rawAvgMargin + ')'
        else
          avgMargin = '(' + rawAvgMargin + ')'
        if formattedGamePct is '1.00'
          formattedGamePct = '1.000'
        formattedPlayers.push
          id: player._id
          name: player.name
          matchRecord: player.matchesWon + '-' + player.matchesLost
          gameRecord: player.gamesWon + '-' + player.gamesLost
          avg: player.avgPtsFor + '-' + player.avgPtsAgainst + ' ' + avgMargin
          avgMargin: rawAvgMargin
          rating: Math.round(player.rating)

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
          id: team._id
          name: team.title
          matchRecord: team.matchesWon + '-' + team.matchesLost
          gameRecord: team.gamesWon + '-' + team.gamesLost
          avg: team.avgPtsFor + '-' + team.avgPtsAgainst + ' ' + avgMargin
          avgMargin: rawAvgMargin
          rating: Math.round(team.rating)

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
      table = <TableView which={'players'} data={@state.players} sorting={{column: 'Rating', direction: 'desc' }}/>
    else
      table = <TableView which={'teams'} data={@state.teams} sorting={{column: 'Rating', direction: 'desc' }}/>

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
