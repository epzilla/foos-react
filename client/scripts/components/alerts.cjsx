React = require 'react/addons'
cx = React.addons.classSet
AlertStore = require 'scripts/stores/alert-store'

Alert = React.createClass
  render: ->
    type = @props.type
    classes = cx(
      'alert': true
      'text-center': true
      'alert-info': type is 'info'
      'alert-danger': type is 'error'
      'alert-warning': type is 'warn'
      'alert-success': type is 'success')

    iconClasses = cx(
      'fa': true
      'fa-info-circle': type is 'info'
      'fa-exclamation-circle': type is 'error'
      'fa-exclamation-triangle': type is 'warn'
      'fa-thumbs-o-up': type is 'success')

    <div className={classes} role="alert">
      <i className={iconClasses}></i>
      <span dangerouslySetInnerHTML={{__html: @props.text}} />
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
    notifications = []

    for alert in @state.alerts
      notifications.push(<Alert text={alert.text} type={alert.type} />)

    <section id="alerts" className="alerts">
      {notifications}
    </section>
