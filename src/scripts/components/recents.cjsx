React = require 'react/addons'
ReactPropTypes = React.PropTypes
FinalBoxScore = require 'scripts/components/final-box-score'

module.exports = React.createClass

  propTypes: {
    recents: ReactPropTypes.array.isRequired
  }

  render: ->

    # If there are no recent matches, render nothing
    if not recents or recents.length < 1
      null

    recents = @props.recents
    recentMatches = []

    for recent in recents
      recentMatches.push(<FinalBoxScore key={recent._id} match={recent} />)

    <section id="recent-matches" className="recent-matches row pad-bottom-1em">
      <div className="row">
        <div className="col-xs-12">
          <h2 className="underline text-center">Recent Matches</h2>
        </div>
      </div>
      <div className="row">
        {recentMatches}
      </div>
    </section>
