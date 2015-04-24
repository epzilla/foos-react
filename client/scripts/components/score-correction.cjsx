React = require 'react/addons'
Router = require 'react-router'
{ActiveState} = Router
ScoreStepper = require 'scripts/components/score-stepper'
MatchStore = require 'scripts/stores/match-store'
Actions = require 'scripts/actions/view-action-creator'
API = require 'scripts/utils/api'
conf = require '../../../conf/config'
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
    teamMap = conf.TEAM_MAP
    blackTitle = ''
    yellowTitle = ''

    if match and match.gameNum
      if match.gameNum is 2
        blackTitle = match[teamMap.game2.black].title
        yellowTitle = match[teamMap.game2.yellow].title
      else
        blackTitle = match[teamMap.game1.black].title
        yellowTitle = match[teamMap.game1.yellow].title


    blackClasses = cx(
      'heads-stepper': true
      'row': true
      'tall': true
      'stepper': true
      'margin-top-1em': true
    )

    yellowClasses = cx(
      'tails-stepper': true
      'row': true
      'tall': true
      'stepper': true
      'margin-top-1em': true
    )

    <section>
      <ScoreStepper classes={blackClasses} code={code} team='black' title={blackTitle}/>
      <ScoreStepper classes={yellowClasses} code={code} team='yellow' title={yellowTitle}/>
      <hr/>
      <div className="row pad-top-1em">
        <div className="col-xs-12 text-center">
          <button className="btn btn-danger end-match">End Match</button>
        </div>
      </div>
    </section>