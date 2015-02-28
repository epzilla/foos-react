mongoose = require('mongoose')
Schema = mongoose.Schema

MatchSchema = new Schema(
  team1:
    type: Schema.Types.ObjectId
    ref: 'Team'
  team2:
    type: Schema.Types.ObjectId
    ref: 'Team'
  winner:
    type: Schema.Types.ObjectId
    ref: 'Team'
  scores: [ {
    team1: Number
    team2: Number
  } ]
  startTime: Date
  endTime: Date
  gameStartTime: Date
  gameNum: Number
  active: Boolean)

module.exports = mongoose.model('Match', MatchSchema)