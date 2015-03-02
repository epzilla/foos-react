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


     # <div className="row">
     #    <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left italicize text-silver underline">
     #      Feb 18, 2015
     #    </div>
     #  </div>
     #  <div className="row">
     #    <div className="col-xs-2 text-right"><i show.bind="match.team1._id == match.winner" className="fa fa-check text-success"></i></div>
     #    <div className="col-xs-5 no-pad-left text-left"><span>${match.team1.title}</span></div>
     #    <div repeat.for="score of match.scores" className="col-xs-1 no-pad text-center ${score.team1 &gt; score.team2 ? &quot;winning-score&quot;             : &quot;&quot;} ${score.team2 &gt; score.team1 ? &quot;losing-score&quot; : &quot;&quot;}">${score.team1}</div>
     #  </div>
     #  <div className="row">
     #    <div className="col-xs-2 text-right"><i show.bind="match.team2._id == match.winner" className="fa fa-check text-success"></i></div>
     #    <div className="col-xs-5 no-pad-left text-left"><span>${match.team2.title}</span></div>
     #    <div repeat.for="score of match.scores" className="col-xs-1 no-pad text-center ${score.team2 &gt; score.team1 ? &quot;winning-score&quot;             : &quot;&quot;} ${score.team1 &gt; score.team2 ? &quot;losing-score&quot; : &quot;&quot;}">${score.team2}</div>
     #  </div>
     #  <div className="row">
     #    <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left footnote"><i className="fa fa-clock-o"></i>&nbsp;Match time: ${match.mins}m</div>
     #  </div>