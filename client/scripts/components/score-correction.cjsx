React = require 'react/addons'
Router = require 'react-router'
{ActiveState} = Router
ScoreStepper = require 'scripts/components/score-stepper'
MatchStore = require 'scripts/stores/match-store'
Actions = require 'scripts/actions/view-action-creator'
API = require 'scripts/utils/api'
cx = React.addons.classSet

getMatchInfo = ->
  {
    match: MatchStore.getCurrentMatch()
  }

module.exports = React.createClass
  mixins: [ActiveState]

  _onChange: ->
    @setState getMatchInfo()

  getInitialState: ->
    getMatchInfo()

  componentDidMount: ->
    MatchStore.addChangeListener @_onChange
    endMatchBtn = document.querySelector '.end-match'

    endMatchBtn.addEventListener 'click', =>
      if window.confirm 'Are you sure you want to end the match?'
        Actions.endMatch(@getActiveQuery().code)

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange

  render: ->
    code = @getActiveQuery().code
    match = @state.match

    team1classes = cx(
      'heads-stepper': match.gameNum isnt 2
      'tails-stepper': match.gameNum is 2
      'row': true
      'tall': true
      'stepper': true
      'margin-top-1em': true
    )

    team2classes = cx(
      'heads-stepper': match.gameNum is 2
      'tails-stepper': match.gameNum isnt 2
      'row': true
      'tall': true
      'stepper': true
      'margin-top-1em': true
    )

    <section>
      <ScoreStepper classes={team1classes} code={code} match={match} teamNum='team1'/>
      <ScoreStepper classes={team2classes} code={code} match={match} teamNum='team2'/>
      <hr/>
      <div className="row pad-top-1em">
        <div className="col-xs-12 text-center">
          <button className="btn btn-danger end-match">End Match</button>
        </div>
      </div>
    </section>