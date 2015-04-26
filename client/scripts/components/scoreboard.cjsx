React = require 'react/addons'
TimeAgo = require './time-ago'
Actions = require 'scripts/actions/view-action-creator'
Router = require 'react-router'
{Navigation} = Router
ScoreStepper = require 'scripts/components/score-stepper'
moment = require 'moment'
ls = require 'scripts/utils/local-storage'
fullscreen = require 'scripts/utils/fullscreen'
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
      <h5>{@props.gameNum}</h5>
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
      , 5000)

  render: ->
    won = @props.score > @props.otherScore && !@props.isCurrentGame
    lost = @props.score < @props.otherScore && !@props.isCurrentGame
    classes = cx(
      'winning-score': won
      'losing-score': lost
      'score-flash': @state.flash)

    <h2 className={classes}>{@props.score}</h2>

module.exports = React.createClass
  mixins: [Navigation]

  componentDidMount: ->
    fullscreenBtn = document.querySelector '.fullscreen-mode'
    notifyBtn = document.querySelector '.notify-btn'

    fullscreenBtn.addEventListener 'click', (e) ->
      scoreboard = document.querySelector '.scoreboard'
      if fullscreenBtn.classList.contains 'btn-success'
        fullscreen.enterFullscreen scoreboard
        fullscreenBtn.innerHTML = '<i class="fa fa-times"></i>Exit Full Screen'
        fullscreenBtn.classList.remove 'btn-success'
        fullscreenBtn.classList.add 'btn-danger'
      else
        fullscreen.exitFullscreen scoreboard
        fullscreenBtn.innerHTML = '<i class="fa fa-arrows-alt"></i>Full Screen'
        fullscreenBtn.classList.add 'btn-success'
        fullscreenBtn.classList.remove 'btn-danger'

    notifyBtn.addEventListener 'click', (e) =>
      console.log 'Notify me'
      @transitionTo '/notify'

    window.addEventListener 'keyup', (e) ->
      if e.keyCode is 27 and btn.classList.contains 'btn-danger'
        btn.innerHTML = 'Full Screen'
        btn.classList.add 'btn-success'
        btn.classList.remove 'btn-danger'

  render: ->
    gameNums = []
    gameScores = []
    match = @props.match
    winner = @props.winner
    gameStart = undefined
    currentUserStartedMatch = match._id is ls.get('matchID')

    if winner
      console.log winner
      gameStatus = <h3>FINAL</h3>
    else
      gameStatus = <h3>Game {match.gameNum} In Progress</h3>

    team1rowClasses = cx(
      'row': true
      'black': match.gameNum isnt 2
      'yellow': match.gameNum is 2
      'winner': winner and winner._id is match.team1._id
    )

    team2rowClasses = cx(
      'row': true
      'yellow': match.gameNum isnt 2
      'black': match.gameNum is 2
      'winner': winner and winner._id is match.team2._id
    )

    i = 1
    while i <= 3
      gameNums.push(<GameNum key={'gameNum' + i} gameNum={i} currentGame={match.gameNum}/>)
      if match.scores.length >= i
        isCurrentGame = match.gameNum is i
        gameScores.push(<GameScoreBox key={'gameScoreBox' + i} scores={match.scores[i-1]} isCurrentGame={isCurrentGame}/>)
      else
        fakeScore =
          team1: 0
          team2: 0
        gameScores.push(<GameScoreBox key={'gameScoreBox' + i} scores={fakeScore} />)
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
                  <div className={team1rowClasses}>
                    <h2>{match.team1.title}</h2>
                  </div>
                  <div className={team2rowClasses}>
                    <h2>{match.team2.title}</h2>
                  </div>
                </div>
                <div className="col-xs-6 no-pad">
                  {gameScores}
                </div>
              </div>
            </div>
            <div className="row text-center">
              {gameStatus}
            </div>
            <div className="row text-center">
              <h5><i className="fa fa-clock-o"></i><em>&nbsp;Match started <TimeAgo time={match.startTime} />.</em></h5>
            </div>
            {gameStart}
            <div className="row pad-top-1em">
              <div className="col-md-2 col-md-offset-4 pad-bottom-1em hidden-xs">
                <button className="btn btn-success fullscreen-mode">
                  <i className="fa fa-arrows-alt"></i>Full Screen
                </button>
              </div>
              <div className="col-md-2">
                <button className="btn btn-info notify-btn">
                  <i className="fa fa-envelope"></i>Notify Me
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
