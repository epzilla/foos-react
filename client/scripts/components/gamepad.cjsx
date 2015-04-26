React = require 'react'
Swipeable = require 'react-swipeable'
displayController = ->


module.exports = React.createClass
  propTypes:
    onChange: React.PropTypes.func

  _clickHandler: (e) ->
    if typeof @props.onChange is 'function'
      @props.onChange
        keyCode: e.target.getAttribute('data-key')

  _intercept: (e) ->
    e.preventDefault()
    e.stopPropagation()

  _dismiss: ->
    document.getElementById('controller').classList.remove 'revealed'

  componentDidMount: ->
    document.querySelector('.gamepad-icon').addEventListener 'touchend', (e) ->
      sound = document.querySelector('audio')

      if sound.src isnt '/sounds/secret/secret.wav'
        sound.src = '/sounds/secret/secret.wav'

      sound.play()
      document.getElementById('controller').classList.add 'revealed'

  render: ->
    <section>
      <div className="gamepad-icon">
        <img src="/images/controller.png" />
      </div>
      <Swipeable onSwipedDown={@_dismiss} onSwipingDown={@_intercept}>
        <div id="controller">
          <div id="d-pad" className="clearfix">
            <button id="up-button" className="d-pad-button" onClick={@_clickHandler} data-key="38">⇓</button>
            <button id="left-button" className="d-pad-button" onClick={@_clickHandler} data-key="37">⇓</button>
            <button id="right-button" className="d-pad-button" onClick={@_clickHandler} data-key="39">⇓</button>
            <button id="down-button" className="d-pad-button" onClick={@_clickHandler} data-key="40">⇓</button>
            <div id="middle-part"></div>
          </div>
          <div className="a-b-btns">
            <button id="b-btn" onClick={@_clickHandler} data-key="66"></button>
            <button id="a-btn" onClick={@_clickHandler} data-key="65"></button>
          </div>
          <div className="gp-dismiss-instruct">
            <span>Swipe ↓ to dismiss</span>
          </div>
        </div>
      </Swipeable>
    </section>
