React = require 'react/addons'
TimeAgo = require './time-ago'
Actions = require 'scripts/actions/view-action-creator'
moment = require 'moment'
ls = require 'scripts/utils/local-storage'
cx = React.addons.classSet

GameNum = React.createClass
  render: ->
    current = true if @props.gameNum is @props.currentGame
    classes = cx(
      'no-pad-xs': true
      'text-center': true
      'col-xs-4': true
      'current': current)

    <div className={classes}>
      <h5>{this.props.gameNum}</h5>
    </div>

GameScoreBox = React.createClass
  render: ->

    <div className="col-xs-4 text-center no-pad-xs">
      <TeamGameScore score={@props.scores.team1} otherScore={@props.scores.team2} isCurrentGame={@props.isCurrentGame}/>
      <TeamGameScore score={@props.scores.team2} otherScore={@props.scores.team1} isCurrentGame={@props.isCurrentGame}/>
    </div>

TeamGameScore = React.createClass
  getInitialState: ->
    {
      flash: false
    }

  componentWillReceiveProps: (nextProps) ->
    if nextProps.score isnt @props.score
      self = this
      self.state.flash = true
      window.setTimeout(->
        self.state.flash = false
        self.getDOMNode().classList.remove 'score-flash'
        return
      , 5000)

  render: ->
    won = @props.score > @props.otherScore && !@props.isCurrentGame
    lost = @props.score < @props.otherScore && !@props.isCurrentGame
    classes = cx(
      'winning-score': won
      'losing-score': lost
      'score-flash': this.state.flash)

    <h2 className={classes}>{@props.score}</h2>

ScoreStepper = React.createClass
  incrementScore: ->
    payload =
      id: @props.match._id
      team: @props.teamNum
      plusMinus: 'plus'

    Actions.changeScore(payload)

  decrementScore: ->
    payload =
      id: @props.match._id
      team: @props.teamNum
      plusMinus: 'minus'

    Actions.changeScore(payload)

  render: ->
    teamNum = @props.teamNum
    title = @props.match[teamNum].title
    classes = @props.classes

    <div className={classes}>
      <div className="col-xs-4 minus no-pad">
        <button onClick={this.decrementScore} className="btn btn-expand"><i className="fa fa-minus"></i></button>
      </div>
      <div className="col-xs-4 flex-container height-3-5em">
        <h3 className="text-center">{title}</h3>
      </div>
      <div className="col-xs-4 plus no-pad">
        <button onClick={this.incrementScore} className="btn btn-expand"><i className="fa fa-plus"></i></button>
      </div>
    </div>


module.exports = React.createClass

  render: ->
    gameNums = []
    gameScores = []
    match = this.props.match
    gameStart = undefined
    scoreSteppers = undefined
    currentUserStartedMatch = match._id is ls.get('matchID')

    if currentUserStartedMatch
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

      scoreSteppers =
        <div>
          <ScoreStepper classes={team1classes} match={match} teamNum='team1'/>
          <ScoreStepper classes={team2classes} match={match} teamNum='team2'/>
        </div>

    i = 1
    while i <= 3
      gameNums.push(<GameNum gameNum={i} currentGame={match.gameNum}/>)
      if match.scores.length >= i
        isCurrentGame = match.gameNum is i
        gameScores.push(<GameScoreBox scores={match.scores[i-1]} isCurrentGame={isCurrentGame}/>)
      else
        fakeScore =
          team1: 0
          team2: 0
        gameScores.push(<GameScoreBox scores={fakeScore} />)
      i++

    if match.gameNum > 1
      gameStart =
        <div className="row text-center">
          <h5><i className="fa fa-clock-o"></i><em>&nbsp;Game {match.gameNum} started <TimeAgo time={match.gameStartTime}/>.</em></h5>
        </div>

    <div>
      <div className="row">
        <div className="col-md-12">
          <div className="jumbotron scoreboard text-center">
            <h1>Current Match</h1>
            <div className="row">
              <div className="col-sm-10 col-sm-offset-1">
                <div className="col-xs-6"></div>
                <div className="col-xs-6">
                  <div className="row">
                    {gameNums}
                  </div>
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-sm-10 col-sm-offset-1">
                <div className="col-xs-6">
                  <div className="row">
                    <h2>{match.team1.title}</h2>
                  </div>
                  <div className="row">
                    <h2>{match.team2.title}</h2>
                  </div>
                </div>
                <div className="col-xs-6 no-pad">
                  {gameScores}
                </div>
              </div>
            </div>
            <div className="row text-center">
              <h3>Game {match.gameNum} In Progress</h3>
            </div>
            <div className="row text-center">
              <h5><i className="fa fa-clock-o"></i><em>&nbsp;Match started <TimeAgo time={match.startTime} />.</em></h5>
            </div>
            {gameStart}
          </div>
        </div>
      </div>
      {scoreSteppers}
    </div>
