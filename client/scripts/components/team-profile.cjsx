React = require 'react'
TeamStore = require 'scripts/stores/team-store'
Actions = require 'scripts/actions/view-action-creator'

getTeamInfo = (id) ->
  {
    team: TeamStore.getTeamInfo(id)
  }

module.exports = React.createClass
  _onChange: ->
    @setState getTeamInfo(@props.params.teamID)

  getInitialState: ->
    getTeamInfo(@props.params.teamID)

  componentDidMount: ->
    TeamStore.addChangeListener @_onChange
    Actions.getTeams()

  componentWillUnmount: ->
    TeamStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    @_onChange()

  render: ->
    team = @state.team
    if team
      teamImgs = []
      team.players.forEach (pl) ->
        teamImgs.push(<img src={pl.img} />)
      matchRecord = team.matchesWon + '-' + team.matchesLost
      gameRecord = team.gamesWon + '-' + team.gamesLost
      <section className="container">
        <div className="row pad-bottom-1em flex-container-small-screen">
          <div className="col-xs-4 team-pics text-right">
            {teamImgs}
          </div>
          <div className="col-xs-8 team-headers">
            <h1>{team.title}</h1>
          </div>
        </div>
        <div className="row text-center">
          <h3>Match Record: {matchRecord}</h3>
        </div>
        <div className="row text-center">
          <h3>Game Record: {gameRecord}</h3>
        </div>
        <div className="row text-center">
          <h3>Avg. Score: {team.avgPtsFor} - {team.avgPtsAgainst}</h3>
        </div>
      </section>
    else
      <section className="container"></section>