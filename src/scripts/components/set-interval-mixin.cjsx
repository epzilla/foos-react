### This mixin provides a simple setInterval method.
#
# Example:
#
#     var Component = React.createClass({
#         ...
#         componentDidMount: function() {
#             this.setInterval(this.doSomething, 1000);
#             this.setInterval(this.doSomethingElse, 5000);
#         }
#         ...
#     });
#
# doSomething is called every second and doSomethingElse is called every five
# seconds. Their intervals will be canceled automatically when the component
# unmounts.
###

SetIntervalMixin =
  componentWillMount: ->
    @intervals = []
    return
  setInterval: (fn, ms) ->
    @intervals.push setInterval(fn, ms)
    return
  componentWillUnmount: ->
    @intervals.forEach clearInterval
    return
module.exports = SetIntervalMixin