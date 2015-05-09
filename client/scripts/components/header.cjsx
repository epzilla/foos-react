React = require 'react/addons'
Router = require 'react-router'
Actions = require 'scripts/actions/view-action-creator'
Settings = require 'scripts/stores/settings-store'
{Link} = Router

getSettings = ->
  {
    muted: Settings.isMuted()
  }

module.exports = React.createClass
  _onChange: ->
    @setState getSettings()

  getInitialState: ->
    getSettings()

  componentDidMount: ->
    Settings.addChangeListener @_onChange

  componentWillUnmount: ->
    Settings.removeChangeListener @_onChange

  render: ->
    if @state.muted
      muteBtn = <button className="btn btn-unmute" onClick={Actions.unmute}>
                  <span className="glyphicon glyphicon-volume-up" aria-hidden="true"></span> Unmute
                </button>
    else
      muteBtn = <button className="btn btn-mute" onClick={Actions.mute}>
                  <span className="glyphicon glyphicon-volume-off" aria-hidden="true"></span> Mute
                </button>

    <nav className="navbar navbar-default navbar-fixed-top" role="navigation">
      <div className="container">
        <div className="navbar-header">
          <a className="navbar-brand" href="#">
            <img className="img img-rounded" src="/images/snappy-foos.jpg" width="40" height="40" />
          </a>
        </div>
        <ul className="nav navbar-nav">
          <li>
            <Link to="home">
              Home
            </Link>
          </li>
          <li>
            <Link to="stats">
              Stats
            </Link>
          </li>
        </ul>
        <ul className="nav navbar-nav pull-right">
          <li>
            {muteBtn}
          </li>
        </ul>
      </div>
    </nav>