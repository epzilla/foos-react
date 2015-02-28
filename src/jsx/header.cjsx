React = require('react/addons')
Router = require('react-router')
{Link} = Router

module.exports = React.createClass
  render: ->
    <div className="ui blue inverted menu">
      <div className="ui page grid">
        <div className="column" style={"padding-bottom": 0}>
          <div className="title item">
            <b>SnappyFoos</b>
          </div>
          <Link className="item" to="home">
            Home
          </Link>
          <Link className="item" to="stats">
            Stats
          </Link>
        </div>
      </div>
    </div>