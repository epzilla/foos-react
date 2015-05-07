React = require 'react'
PlayerStore = require 'scripts/stores/player-store'
Actions = require 'scripts/actions/view-action-creator'
Router = require 'react-router'
{Link, State} = Router

getPlayerInfo = (id) ->
  {
    player: PlayerStore.getPlayerInfo(id)
    fileToUpload: undefined
  }

module.exports = React.createClass
  mixins: [ State ]

  _onChange: ->
    @setState getPlayerInfo(@getParams().playerID)

  _handleFiles: (e) ->
    self = this
    if e.target.files[0]
      @state.fileToUpload = e.target.files[0]

  _submitPic: (e) ->
    e.preventDefault()
    formData = new FormData()
    formData.append('img', @state.fileToUpload)
    formData.append('player', JSON.stringify(@state.player))
    Actions.submitPic formData

  getInitialState: ->
    getPlayerInfo(@getParams().playerID)

  componentDidMount: ->
    PlayerStore.addChangeListener @_onChange
    Actions.getPlayers()

  componentWillUnmount: ->
    PlayerStore.removeChangeListener @_onChange

  componentWillReceiveProps: ->
    @_onChange()

  render: ->
    player = @state.player
    <section>
      <h1>{player.name}</h1>
      <form onSubmit={@_submitPic} role="form" name="pic-upload" id="pic-upload" encType="multipart/form-data">
        <img src={player.img} className="img-responsive img-rounded" />
        <input type="file" name="img" onChange={@_handleFiles}/>
        <input type="submit" value="Submit" />
      </form>
    </section>