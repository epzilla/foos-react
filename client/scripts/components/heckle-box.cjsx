React = require 'react/addons'
Announcer = require 'scripts/utils/announcer'


module.exports = React.createClass

  _close: ->
    document.querySelector('.heckle-box').classList.remove 'revealed'

  _heckle: (e) ->
    if e.target.nodeName is 'BUTTON'
      player = e.target.getAttribute 'data-player'
    else if e.target.nodeName is 'SPAN'
      player = e.target.parentNode.getAttribute 'data-player'

    Announcer.heckle player

  render: ->
    buttons = []
    if @props.players and @props.players.length > 0
      @props.players.forEach (pl) =>
        buttons.push <button className="btn btn-danger" data-player={pl} onClick={@_heckle}>Heckle {pl}</button>

    <section className='heckle-box'>
      <div className="close" onClick={@_close}></div>
      <div>
        {buttons}
      </div>
      <div>
        <button className="btn btn-success rando" onClick={@_heckle}>Generic Heckle</button>
      </div>
    </section>