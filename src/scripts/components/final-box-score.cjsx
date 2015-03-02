React = require 'react/addons'
ReactPropTypes = React.PropTypes

module.exports = React.createClass

  propTypes: {
    match: ReactPropTypes.object.isRequired
  }

  render: ->
    match = this.props.match

    <div className="row pad-bottom-1em">
      <div className="row">
        <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left italicize text-silver underline">
          Feb 18, 2015
        </div>
      </div>
      <div className="row">
        <div className="col-xs-2 text-right"><i className="fa fa-check text-success"></i></div>
        <div className="col-xs-5 no-pad-left text-left">
          <span>Epling / Copley</span>
        </div>
        <div className="col-xs-1 no-pad text-center winning-score">10</div>
        <div className="col-xs-1 no-pad text-center losing-score">7</div>
        <div className="col-xs-1 no-pad text-center winning-score">10</div>
      </div>
      <div className="row">
        <div className="col-xs-2 text-right"></div>
        <div className="col-xs-5 no-pad-left text-left"><span>Chung / Newberry</span></div>
        <div className="col-xs-1 no-pad text-center">6</div>
        <div className="col-xs-1 no-pad text-center">10</div>
        <div className="col-xs-1 no-pad text-center">8</div>
      </div>
      <div className="row">
        <div className="col-xs-10 no-pad-left col-xs-offset-2 text-left footnote">
          <i className="fa fa-clock-o"></i>&nbsp;Match time: 18m
        </div>
      </div>
    </div>