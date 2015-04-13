React = require 'react/addons'
Actions = require 'scripts/actions/view-action-creator'

module.exports = React.createClass

  _submit: (e) ->
    e.preventDefault()
    email = @refs.field.getDOMNode().value
    Actions.submitEmail email
    @refs.field.getDOMNode().value  = ''

  render: ->

    <section className="container">
      <div className="row">
        <div className="col-md-12 text-center">
          <div className="row">
            <h1>Notify Me!</h1>
          </div>
          <form onSubmit={@_submit} role="form" className="notify-form">
            <div className="row pad-bottom-1em">
              <p>Enter your email address below and we'll notify you when the
                 current match ends:</p>
            </div>
            <div className="row pad-bottom-1em">
              <input className="email-notify"
                     autoFocus="true" type="email" ref="field"
                     placeholder="snappy.cat@synapse-wireless.com" />
            </div>
            <div className="row">
              <button type="submit" className="btn btn-primary submit">Notify Me</button>
            </div>
          </form>
        </div>
      </div>
    </section>
