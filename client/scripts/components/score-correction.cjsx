React = require 'react/addons'
Router = require 'react-router'
{State} = Router
ScoreStepper = require 'scripts/components/score-stepper'
MatchStore = require 'scripts/stores/match-store'
Actions = require 'scripts/actions/view-action-creator'
cx = React.addons.classSet

getMatchInfo = ->
  {
    match: MatchStore.getCurrentMatch()
  }

module.exports = React.createClass
  mixins: [ State ]

  _onChange: ->
    @setState getMatchInfo()

  getInitialState: ->
    getMatchInfo()

  componentDidMount: ->
    MatchStore.addChangeListener @_onChange
    endMatchBtn = document.querySelector '.end-match'

    endMatchBtn.addEventListener 'click', =>
      if window.confirm 'Are you sure you want to end the match?'
        Actions.endMatch(@getQuery().code)

  componentWillUnmount: ->
    MatchStore.removeChangeListener @_onChange

  render: ->
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
      <ScoreStepper
        classes={blackClasses}
        code={@props.code}
        team='black'
        title={@props.blackTitle} />
      <ScoreStepper
        className="tails-stepper row tall stepper margin-top-1em"
        classes={yellowClasses}
        code={@props.code}
        team='yellow'
        title={@props.yellowTitle} />
      <hr/>
      <div className="row pad-top-1em">
        <div className="col-xs-12 text-center">
          <button className="btn btn-danger end-match">End Match</button>
        </div>
      </div>
    </section>