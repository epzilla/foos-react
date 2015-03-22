React = require 'react/addons'
cx = React.addons.classSet
AlertStore = require 'scripts/stores/alert-store'

Alert = React.createClass
  render: ->
    type = @props.type
    classes = cx(
      'alert': true
      'alert-info': true if type is 'info' else false
      'alert-danger': true if type is 'error' else false
      'alert-warning': true if type is 'warn' else false
      'alert-success': true if type is 'success' else false)

    iconClasses = cx(
      'fa': true
      'fa-info-circle': true if type is 'info' else false
      'fa-exclamation-circle': true if type is 'error' else false
      'fa-exclamation-triangle': true if type is 'warn' else false
      'fa-check-circle': true if type is 'success' else false)

    <div className={classes} role="alert">
      <i className={iconClasses}></i>
      {@props.text}
    </div>

module.exports = React.createClass
  _getAlerts: ->
    {
      alerts: AlertStore.getAlerts()
    }

  _onChange: ->
    @setState @_getAlerts()

  getInitialState: ->
    @_getAlerts()

  componentDidMount: ->
    AlertStore.addChangeListener @_onChange

  render: ->
    alerts = []
    notifications = []

    for alert in alerts
      notifications.push(<Alert text={alert.text} type={alert.type} />)

    <section id="alerts" className="alerts">
      {notifications}
    </section>
