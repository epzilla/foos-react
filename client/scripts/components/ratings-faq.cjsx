React = require 'react/addons'

module.exports = React.createClass

  render: ->
    <article className="row ratings-faq">
      <section className="col-md-12 text-left">
        <h2>How Are Ratings Calculated?</h2>
        <p>The rating system in SnappyFoos uses a modified version of the&nbsp;
           <a href="http://en.wikipedia.org/wiki/Elo_rating_system">Elo Rating System</a>, made famous in chess,
           and widely used for player/team ratings in other sports as well.</p>
        <p>Each new player enters the system with a rating of 1000, which can go up or down after each match played.
           The rating system as a whole is a zero sum game, meaning that the winner essentially takes points away
           from the loser, e.g. if one player moves up 10 points after a win, the losing player would move down 10 points.</p>
        <p>The amount of points to be gained or lost is calculated by first coming up with a prediction of which team&nbsp;
           <em>should</em> win, based off their current rankings, and then comparing that result to what actually happened.
           If Team A is rated much higher than Team B, they are expected to win all 3 games of a given match. If they only win
           2, they will still gain points, but not as many as they would have if they'd won all 3 like they were "supposed to".
           Scoring margin also plays a small factor in how teams move up and down. If Team A wins all 3 games, but not convincingly, they may
           again not move up by as many points.</p>
        <p>With the current parameters, the maximum amount of points on the line (the "K-value", in Elo rating terms) is set to
           32. This means that if one team completely annihilates another (and the system didn't predict that would be the case),
           they'll move up 16 points, and the other team will move down 16 points.</p>
        <p>Each player has an individual player rating, and each team has a rating that is calculated the first time they play
           as a team, by averaging the two players' ratings. The team and player ratings will adjust by the same amount per game.</p>
        <p>After each completed match, a script runs that updates the 4 participating players' ratings and their respective
           team ratings. After the new ratings are calculated, the player and team rankings are re-calculated as well.</p>
        <p>You can read more about the Elo rating system <a href="http://en.wikipedia.org/wiki/Elo_rating_system">here</a>.</p>
        <p>The library used to run the ratings system can be found <a href="https://github.com/dmamills/elo-rank">here</a>.</p>
      </section>
    </article>