React = require 'react'
PlayerStore = require 'scripts/stores/player-store'
Actions = require 'scripts/actions/view-action-creator'
Router = require 'react-router'
FinalBoxScore = require 'scripts/components/final-box-score'
{Link, State} = Router
_ = require 'lodash'

getPlayerInfo = (id) ->
  {
    player: PlayerStore.getPlayerInfo(id)
    players: _.filter(PlayerStore.getPlayers(), (pl) ->
              pl.rank
            )
    playerMatches: PlayerStore.getPlayerMatches()
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
    Actions.getPlayerMatches(@getParams().playerID)

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    Actions.getPlayerMatches(@getParams().playerID)
    @_onChange()

  render: ->
    player = @state.player
    players = _.sortBy(@state.players, 'rank')
    playerMatches = @state.playerMatches

    if player
      matchRecord = player.matchesWon + '-' + player.matchesLost
      gameRecord = player.gamesWon + '-' + player.gamesLost
      rawMargin = (parseFloat(player.avgPtsFor) - parseFloat(player.avgPtsAgainst)).toFixed(1)
      margin = if rawMargin > 0 then '+' + rawMargin else rawMargin
      playerLinks = []
      matches = []

      players.forEach (pl) ->
        playerLinks.push(
          <Link className="list-group-item" to="players" params={{playerID: pl._id}} key={pl._id}>
            <table className="table table-transparent list-group-table">
              <tr>
                <td className="col-xs-2">{pl.rank}.</td>
                <td className="col-xs-6">{pl.name}</td>
                <td className="col-xs-4 text-center">{Math.round(pl.rating)}</td>
              </tr>
            </table>
          </Link>
        )

      if playerMatches and playerMatches.length > 0
        playerMatches.forEach (m) ->
          matches.push <FinalBoxScore key={m._id} match={m} />

      <div className="container">
        <div className="row">
          <div className="col-md-8">
            <div className="row">
              <div className="col-md-8">
                <h1 className="hidden-xs hidden-sm">{player.name}</h1>
                <div className="col-xs-12 visible-xs visible-sm pad-bottom-1em">
                  <div className="col-xs-6">
                    <h1>{player.name}</h1>
                  </div>
                  <div className="col-xs-6 pad-top-1em">
                    <Link to="playerpic" params={{playerID: player._id}}>
                      <img src={player.img} className="img-responsive img-rounded" />
                    </Link>
                  </div>
                </div>
                <br />
                <table className="table table-transparent">
                  <tr>
                    <td><strong>Ranking</strong></td>
                    <td>{player.rank or '—'}</td>
                  </tr>
                  <tr>
                    <td><strong>Points</strong></td>
                    <td>{Math.round(player.rating)}</td>
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
              <div className="col-md-4 hidden-xs hidden-sm pad-top-1em">
                <Link to="playerpic" params={{playerID: player._id}}>
                  <img src={player.img} className="img-responsive img-rounded"/>
                </Link>
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
            <h4>Player Rankings</h4>
            <div className="list-group">
              {playerLinks}
            </div>
          </div>
        </div>
      </div>

    else
      <section className="container"></section>