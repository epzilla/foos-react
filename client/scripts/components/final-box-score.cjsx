React = require 'react/addons'
ReactPropTypes = React.PropTypes
moment = require 'moment'

module.exports = React.createClass

  propTypes: {
    match: ReactPropTypes.object.isRequired
  }

  render: ->
    match = @props.match
    team1scores = []
    team2scores = []
    team1checkmark = null
    team2checkmark = null
    prediction = null

    # Date and time formatting for display
    start = moment(match.startTime)
    end = moment(match.endTime)
    formattedDate = moment(match.endTime).format 'MMMM D'
    duration = end.diff(start, 'minutes')

    # Determine the winner
    team1wins = match.winner is match.team1._id

    # If team 1 wins, add the checkmark next to their name, else add it to team 2
    if team1wins
      team1checkmark = <i className="fa fa-check text-success"></i>
    else
      team2checkmark = <i className="fa fa-check text-success"></i>

    if match.prediction
      prediction = <div className="row">
                     <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left footnote small-font pad-top-1em">
                       The Oracle predicted: {match.prediction.quickString}
                     </div>
                   </div>


    # Collect the game scores
    for score, i in match.scores
      if score.team1 > score.team2
        team1scores.push(<div key={match._id + 'team1' + i} className="col-xs-1 no-pad text-center winning-score">{score.team1}</div>)
        team2scores.push(<div key={match._id + 'team2' + i} className="col-xs-1 no-pad text-center losing-score">{score.team2}</div>)
      else
        team1scores.push(<div key={match._id + 'team1' + i} className="col-xs-1 no-pad text-center losing-score">{score.team1}</div>)
        team2scores.push(<div key={match._id + 'team2' + i} className="col-xs-1 no-pad text-center winning-score">{score.team2}</div>)

    <div className="row pad-bottom-1em">
      <div className="final-box-score">
        <div className="row">
          <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left italicize text-silver underline">
            {formattedDate}
          </div>
        </div>
        <div className="row">
          <div className="col-xs-2 text-right pad-right-5px-mobile">{team1checkmark}</div>
          <div className="col-xs-5 no-pad-left text-left">
            <span>{match.team1.title}</span>
          </div>
          <div>{team1scores}</div>
        </div>
        <div className="row">
          <div className="col-xs-2 text-right pad-right-5px-mobile">{team2checkmark}</div>
          <div className="col-xs-5 no-pad-left text-left">
            <span>{match.team2.title}</span>
          </div>
          <div>{team2scores}</div>
        </div>
        <div className="row">
          <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left footnote">
            <i className="fa fa-clock-o"></i>&nbsp;Match time: {duration}m
          </div>
        </div>
        {prediction}
      </div>
    </div>