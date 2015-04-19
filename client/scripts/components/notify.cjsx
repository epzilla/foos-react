React = require 'react/addons'
Actions = require 'scripts/actions/view-action-creator'
CarrierStore = require 'scripts/stores/carrier-store'
API = require 'scripts/utils/api'
Select = require 'react-select'
MaskedInput = require 'react-maskedinput'
_ = require 'lodash'

getCarriers = ->
  {
    carriers: CarrierStore.getCarriers()
    selectedCarrier: undefined
  }

module.exports = React.createClass

  _onChange: ->
    @setState getCarriers()

  _selectCarrier: (val, selectedOptions) ->
    @state.selectedCarrier = val

  _thisIsSilly: (e) ->
    # Apparently MaskedInput insists we put an onChange method in,
    # even if we don't want to do anything with it

  _submitEmail: (e) ->
    e.preventDefault()
    email = @refs.emailField.getDOMNode().value
    Actions.submitEmail email
    @refs.emailField.getDOMNode().value  = ''

  _submitText: (e) ->
    e.preventDefault()
    numParts = @refs.textField.getDOMNode().value.replace(/_/, '').split('-')
    num = numParts[0] + numParts[1] + numParts[2]
    carrier = @state.selectedCarrier
    if num and num.length is 10 and carrier
      Actions.submitSMS num + '@' + carrier
      console.log num
      @refs.textField.getDOMNode().value  = ''

  getInitialState: ->
    getCarriers()

  componentDidMount: ->
    CarrierStore.addChangeListener @_onChange
    API.getCarriers()

  componentWillUnmount: ->
    CarrierStore.removeChangeListener @_onChange

  render: ->

    options = []
    _.forEach(@state.carriers, (el) ->
      carrier =
        value: el.suffix
        label: el.name
      options.push carrier
    )

    <section className="container">
      <div className="row">
        <div className="col-md-12 text-center">
          <div className="row">
            <h1>Notify Me!</h1>
          </div>
          <div className="row pad-bottom-1em">
            <p>Enter your info below and we'll notify you when the
               current match ends:</p>
          </div>
          <form onSubmit={@_submitEmail} role="form" className="notify-form">
            <div className="form-group">
              <label htmlFor="email-notify">Via Email:</label>
              <input className="email-notify" name="email-notify"
                       autoFocus="true" type="email" ref="emailField"
                       placeholder="snappy.cat@synapse-wireless.com" />
              <button type="submit" className="btn btn-primary submit"><i className="fa fa-envelope"></i>Email Me</button>
            </div>
          </form>
          <hr/>
          <form onSubmit={@_submitText} role="form" className="notify-form sms-form">
            <div className="form-group">
              <label htmlFor="text-notify">Via Text:</label>
              <MaskedInput pattern="111-111-1111" placeholder="123-456-7890"
                           className="email-notify" name="text-notify"
                           type="tel" ref="textField"
                           onChange={@_thisIsSilly}
                           required="required"/>
              <Select options={options} onChange={@_selectCarrier} placeholder="Select Your Carrier..." required="required"/>
              <button type="submit" className="btn btn-primary submit"><i className="fa fa-mobile"></i>Text Me</button>
            </div>
          </form>
        </div>
      </div>
    </section>
