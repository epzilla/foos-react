React = require 'react'
TeamStore = require 'scripts/stores/team-store'
Actions = require 'scripts/actions/view-action-creator'
Router = require 'react-router'
FinalBoxScore = require 'scripts/components/final-box-score'
{Link, State} = Router
_ = require 'lodash'

getTeamInfo = (id) ->
  {
    team: TeamStore.getTeamInfo(id)
    teams: _.filter(TeamStore.getTeams(), (tm) ->
            tm.rank
          )
    teamMatches: TeamStore.getTeamMatches()
  }

module.exports = React.createClass
  mixins: [ State ]

  _onChange: ->
    @setState getTeamInfo(@getParams().teamID)

  getInitialState: ->
    getTeamInfo(@getParams().teamID)

  componentDidMount: ->
    TeamStore.addChangeListener @_onChange
    Actions.getTeams()
    Actions.getTeamMatches(@getParams().teamID)

  componentWillUnmount: ->
    TeamStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    Actions.getTeamMatches(@getParams().teamID)
    @_onChange()

  render: ->
    team = @state.team
    teams = _.sortBy(@state.teams, 'rank')
    teamMatches = @state.teamMatches

    if team
      teamImgs = []
      team.players.forEach (pl) ->
        teamImgs.push(<img key={pl._id} src={pl.img} className="img-responsive img-rounded"/>)
      matchRecord = team.matchesWon + '-' + team.matchesLost
      gameRecord = team.gamesWon + '-' + team.gamesLost
      rawMargin = (parseFloat(team.avgPtsFor) - parseFloat(team.avgPtsAgainst)).toFixed(1)
      margin = if rawMargin > 0 then '+' + rawMargin else rawMargin
      teamLinks = []
      matches = []

      teams.forEach (tm) ->
        teamLinks.push(
          <Link className="list-group-item" to="teams" params={{teamID: tm._id}} key={tm._id}>
            <table className="table table-transparent list-group-table">
              <tr>
                <td className="col-xs-2">{tm.rank}.</td>
                <td className="col-xs-6">{tm.title}</td>
                <td className="col-xs-4 text-center">{Math.round(tm.rating)}</td>
              </tr>
            </table>
          </Link>
        )

      if teamMatches and teamMatches.length > 0
        teamMatches.forEach (m) ->
          matches.push <FinalBoxScore key={m._id} match={m} />

      <section className="container">
        <div className="row">
          <div className="col-md-8">
            <div className="row">
              <div className="col-md-8">
                <h1 className="hidden-sm hidden-xs">{team.title}</h1>
                <div className="col-xs-12 visible-sm visible-xs pad-bottom-1em">
                  <div className="col-xs-6">
                    <h1>{team.title}</h1>
                  </div>
                  <div className="col-xs-6 pad-top-1em">
                    <div className="row no-pad">
                      <div className="col-xs-6 no-pad">
                        {teamImgs[0]}
                      </div>
                      <div className="col-xs-6 no-pad">
                        {teamImgs[1]}
                      </div>
                    </div>
                  </div>
                </div>
                <br />
                <table className="table table-transparent">
                  <tr>
                    <td><strong>Ranking</strong></td>
                    <td>{team.rank or '—'}</td>
                  </tr>
                  <tr>
                    <td><strong>Points</strong></td>
                    <td>{Math.round(team.rating)}</td>
                  </tr>
                  <tr>
                    <td><strong>Match Record</strong></td>
                    <td>{matchRecord}</td>
                  </tr>
                  <tr>
                    <td><strong>Game Record</strong></td>
                    <td>{gameRecord}</td>
                  </tr>
                  <tr>
                    <td><strong>Avg. Scoring Margin</strong></td>
                    <td>{margin}</td>
                  </tr>
                </table>
              </div>
              <div className="col-md-4 hidden-sm hidden-xs pad-top-1em">
                <div className="row">
                  <div className="col-md-6">
                    {teamImgs[0]}
                  </div>
                  <div className="col-md-6">
                    {teamImgs[1]}
                  </div>
                </div>
              </div>
            </div>
            <div className="page-header">
              <h3>Match History</h3>
            </div>
            <div className="row text-left">
              <div className="col-md-12">
               {matches}
              </div>
            </div>
          </div>
          <div className="col-md-4">
            <h4>Team Rankings</h4>
            <div className="list-group">
              {teamLinks}
            </div>
          </div>
        </div>
      </section>

    else
      <section className="container"></section>