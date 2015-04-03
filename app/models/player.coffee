mongoose = require('mongoose')
Schema = mongoose.Schema

PlayerSchema = new Schema(
  name: String
  nfc: String
  matches: Number
  games: Number
  matchesWon: Number
  matchesLost: Number
  gamesWon: Number
  gamesLost: Number
  pct: Number
  ptsFor: Number
  ptsAgainst: Number
  avgPtsFor: Number
  avgPtsAgainst: Number)

module.exports = mongoose.model('Player', PlayerSchema)