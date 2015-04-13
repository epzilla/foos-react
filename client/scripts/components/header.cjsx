React = require 'react/addons'
Router = require 'react-router'
{Link} = Router

module.exports = React.createClass
  render: ->
    <nav className="navbar navbar-default navbar-fixed-top" role="navigation">
      <div className="container">
        <div className="navbar-header">
          <a className="navbar-brand" href="#">
            <img className="img img-rounded" src="images/snappy-foos.jpg" width="40" height="40" />
          </a>
        </div>
        <ul className="nav navbar-nav">
          <li>
            <Link to="home">
              Home
            </Link>
          </li>
          <li>
            <Link to="stats">
              Stats
            </Link>
          </li>
        </ul>
      </div>
    </nav>