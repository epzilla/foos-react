Constants = require 'scripts/constants/constants'
Dispatcher = require('flux').Dispatcher
assign = require 'object-assign'
PayloadSources = Constants.PayloadSources

AppDispatcher = assign(new Dispatcher, {
  handleServerAction: (action) ->
    payload =
      source: PayloadSources.SERVER_ACTION
      action: action

    @dispatch payload
    return

  handleViewAction: (action) ->
    payload =
      source: PayloadSources.VIEW_ACTION
      action: action

    @dispatch payload
    return

  handleRequestAction: (action) ->
    payload =
      source: PayloadSources.REQUEST_ACTION
      action: action

    @dispatch payload
    return
})

module.exports = AppDispatcher