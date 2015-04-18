mongoose = require('mongoose')
Schema = mongoose.Schema

CarrierSchema = new Schema(
  name: String
  suffix: String
)

module.exports = mongoose.model('Carrier', CarrierSchema)