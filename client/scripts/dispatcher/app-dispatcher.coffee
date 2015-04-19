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

  handleViewAction: (action) ->
    payload =
      source: PayloadSources.VIEW_ACTION
      action: action

    @dispatch payload

  handleRequestAction: (action) ->
    payload =
      source: PayloadSources.REQUEST_ACTION
      action: action

    @dispatch payload
})

module.exports = AppDispatcher