React = require 'react/addons'
Navigation = require('react-router').Navigation
PlayerStore = require 'scripts/stores/player-store'
Actions = require 'scripts/actions/view-action-creator'
Select = require 'react-select'

getPlayerInfo = ->
  {
    nfc: PlayerStore.getUnrecognizedNFC()
    players: PlayerStore.getPlayers()
    selectedPlayer: {}
    newPlayerCreated: PlayerStore.getNewPlayerInfo()
  }

module.exports = React.createClass
  mixins: [Navigation]

  _onPlayerChange: ->
    @setState getPlayerInfo()
    if @state.didTimeout
      @transitionTo '/'
    else if @state.newPlayerCreated
      @transitionTo '/playerRegistration'

  _selectPlayer: (val, selectedOptions) ->
    @state.selectedPlayer = val

  _register: (e) ->
    e.preventDefault()
    console.log('NFC: ' + @state.nfc)
    console.log('Player: ' + @state.selectedPlayer)
    Actions.registerPlayerNFC @state.nfc, @state.selectedPlayer
    return

  componentDidMount: ->
    PlayerStore.addChangeListener @_onPlayerChange

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onPlayerChange

  getInitialState: ->
    getPlayerInfo()

  render: ->
    options = []

    _.forEach(@state.players, (el) ->
      player =
        value: el._id
        label: el.name
      options.push player
      return
    )

    <section className="text-center container">
      <h1>Who does this belong to?</h1>
      <h2>NFC Tag: {@state.nfc}</h2>
      <form onSubmit={@_register} role="form" className="new-player-tag-form">
        <div className="pad-bottom-1em">
          <Select options={options} onChange={@_selectPlayer}/>
        </div>
        <button type="submit" className="btn btn-primary btn-lg">Submit</button>
      </form>
    </section>