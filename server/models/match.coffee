mongoose = require('mongoose')
Schema = mongoose.Schema
deepPopulate = require 'mongoose-deep-populate'

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
  players: [Schema.Types.ObjectId]
  startTime: Date
  endTime: Date
  gameStartTime: Date
  gameNum: Number
  active: Boolean
  prediction: Schema.Types.Mixed)

MatchSchema.plugin(deepPopulate)
module.exports = mongoose.model('Match', MatchSchema)