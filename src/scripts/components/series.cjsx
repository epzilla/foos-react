React = require 'react/addons'
ReactPropTypes = React.PropTypes
FinalBoxScore = require 'scripts/components/final-box-score'

module.exports = React.createClass

  propTypes: {
    series: ReactPropTypes.object.isRequired
  }

  render: ->
    matches = if @props.series then @props.series.matches else []
    quickStats = if @props.series then @props.series.quickStats else null
    seriesMatches = []
    stats = null

    if quickStats
      stats =
        <section id="quick-stats" className="pad-bottom-1em">
          <div className="row">
            <div className="col-xs-12 text-center">
              <h4>{quickStats.matchRecord}</h4>
            </div>
          </div>
          <div className="row">
            <div className="col-xs-12 text-center">
              <strong>Game Record: </strong>&nbsp;<span>{quickStats.gameRecord}</span>
            </div>
          </div>
          <div className="row">
            <div className="col-xs-12 text-center">
              <strong>Average Score: </strong>&nbsp;<span>{quickStats.avg}</span>
            </div>
          </div>
        </section>

    for match in matches
      seriesMatches.push(<FinalBoxScore key={match._id} match={match} />)

    <section id="series-history" className="series-history row pad-bottom-1em">
      <div className="row">
        <div className="col-xs-12">
          <h2 className="underline text-center">Series History</h2>
        </div>
      </div>
      {stats}
      <div className="row text-center">
        <p className="underline">Past Results</p>
      </div>
      <div className="row">
        {seriesMatches}
      </div>
    </section>
