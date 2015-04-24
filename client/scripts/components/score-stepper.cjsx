React = require 'react/addons'
Actions = require 'scripts/actions/view-action-creator'

module.exports = React.createClass
  incrementScore: ->
    payload =
      team: @props.team
      code: @props.code
      plusMinus: 'plus'

    Actions.changeScore(payload)

  decrementScore: ->
    payload =
      team: @props.team
      code: @props.code
      plusMinus: 'minus'

    Actions.changeScore(payload)

  render: ->
    teamNum = @props.team
    title = @props.title
    classes = @props.classes

    <div className={classes}>
      <div className="col-xs-4 minus no-pad">
        <button onClick={@decrementScore} className="btn btn-expand"><i className="fa fa-minus"></i></button>
      </div>
      <div className="col-xs-4 flex-container height-3-5em">
        <h3 className="text-center">{title}</h3>
      </div>
      <div className="col-xs-4 plus no-pad">
        <button onClick={@incrementScore} className="btn btn-expand"><i className="fa fa-plus"></i></button>
      </div>
    </div>