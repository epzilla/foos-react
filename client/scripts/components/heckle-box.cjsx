React = require 'react/addons'
Swipeable = require 'react-swipeable'
Actions = require 'scripts/actions/view-action-creator'
Announcer = require 'scripts/utils/announcer'

module.exports = React.createClass
  _intercept: (e) ->
    e.preventDefault()
    e.stopPropagation()

  _dismiss: (e) ->
    document.querySelector('.heckle-box').classList.remove 'revealed'

  _heckle: (e) ->
    if e.target.nodeName is 'BUTTON'
      player = e.target.getAttribute 'data-player'
    else if e.target.nodeName is 'SPAN'
      player = e.target.parentNode.getAttribute 'data-player'

    Actions.heckle player

  render: ->
    buttons = []
    dismissalElement = undefined

    swipeToDismiss = <div className="dismiss-instructions">Swipe ↓ to dismiss</div>
    clickToDismiss = <div className="close" onClick={@_dismiss}></div>
    if @props.players and @props.players.length > 0
      @props.players.forEach (pl) =>
        buttons.push <button key={'heckle' + pl} className="btn btn-danger" data-player={pl} onClick={@_heckle}>Heckle {pl}</button>

    `if ('ontouchstart' in window) {
       dismissalElement = swipeToDismiss
     } else {
       dismissalElement = clickToDismiss
     }`

    <Swipeable onSwipedDown={@_dismiss} onSwipingDown={@_intercept} className='heckle-box'>
      {dismissalElement}
      <div>
        {buttons}
      </div>
      <div>
        <button className="btn btn-success rando" onClick={@_heckle}>Generic Heckle</button>
      </div>
    </Swipeable>