mongoose = require('mongoose')
Schema = mongoose.Schema

TeamSchema = new Schema(
  title: String
  players: [ {
    type: Schema.Types.ObjectId
    ref: 'Player'
  } ]
  matches: Number
  games: Number
  matchesWon: Number
  matchesLost: Number
  gamesWon: Number
  gamesLost: Number
  pct: Number
  ptsFor: Number
  ptsAgainst: Number
  rank: Number
  rating: Number
  avgPtsFor: Number
  avgPtsAgainst: Number)

module.exports = mongoose.model('Team', TeamSchema)