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

    recents = this.props.recents
    recentMatches = []

    for recent in recents
      recentMatches.push(<FinalBoxScore key={recent._id} match={recent} />)

    <section id="recent-matches" className="recent-matches row pad-bottom-1em">
      {recentMatches}
    </section>
