React = require 'react/addons'
_ = require 'lodash'
PlayerStore = require 'scripts/stores/player-store'
MatchStore = require 'scripts/stores/match-store'
API = require 'scripts/utils/api'
Navigation = require('react-router').Navigation
Actions = require 'scripts/actions/view-action-creator'
Select = require 'react-select'

module.exports = React.createClass
  mixins: [Navigation]

  _onChange: ->
    @setState(
      players: PlayerStore.getPlayers()
    )

  _onMatchChange: ->
    match = MatchStore.getCurrentMatch()
    if match and match.hasOwnProperty('active') and match.active
      @transitionTo '/'

  selectHeadsOne: (val, selectedOptions)->
    @state.selectedPlayers.team1[0] = val

  selectHeadsTwo: (val, selectedOptions)->
    @state.selectedPlayers.team1[1] = val

  selectTailsOne: (val, selectedOptions)->
    @state.selectedPlayers.team2[0] = val

  selectTailsTwo: (val, selectedOptions)->
    @state.selectedPlayers.team2[1] = val

  startMatch: (e) ->
    e.preventDefault()
    Actions.startMatch(@state.selectedPlayers)

  getInitialState: ->
    players: []
    selectedPlayers:
      team1: []
      team2: []

  componentWillMount: ->
    match = MatchStore.getCurrentMatch()
    if match and match.hasOwnProperty('active') and match.active
      @render = ->
        false
      @goBack()

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    MatchStore.addChangeListener @_onMatchChange
    Actions.getPlayers()

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange
    MatchStore.removeChangeListener @_onMatchChange

  render: ->
    options = []

    _.forEach(@state.players, (el) ->
      player =
        value: el._id
        label: el.name
      options.push player
    )

    <section className="text-center container">
      <h1>Start New Match</h1>
      <form onSubmit={@startMatch} role="form" className="new-match-form">
        <h3>Heads</h3>
        <div className="heads-form">
          <Select options={options} onChange={@selectHeadsOne}/>
          <Select options={options} onChange={@selectHeadsTwo}/>
        </div>
        <h3>Tails</h3>
        <div className="pad-bottom-1em tails-form">
          <Select options={options} onChange={@selectTailsOne}/>
          <Select options={options} onChange={@selectTailsTwo}/>
        </div>
        <button type="submit" className="btn btn-primary btn-lg">Submit</button>
      </form>
    </section>