### The equivalent to jQuery.timeago for react.
#
# TimeAgo returns a span containing the amount of time (in English) that has
# passed since `time`.
#
# Takes:
#     time: an ISO 8601 timestamp
#     refreshMillis: how often to update, in milliseconds
#
# Example:
#
#     return <a href={khanAcademy}><TimeAgo time={date} /></a>
###

React = require('react')
SetIntervalMixin = require('./set-interval-mixin')
moment = require('moment')
# TODO(joel) i18n
TimeAgo = React.createClass(
  mixins: [ SetIntervalMixin ]
  render: ->
    <span>{moment(@props.time).fromNow()}</span>
  componentDidMount: ->
    interval = @props.refreshMillis or 60000
    # TODO(joel) why did I have to bind forceUpdate?
    @setInterval @forceUpdate.bind(this), interval
    return
)
module.exports = TimeAgo