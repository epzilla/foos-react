mongoose = require('mongoose')
Schema = mongoose.Schema

NotificationSchema = new Schema(
  email: String
  type: String
)

module.exports = mongoose.model('Notification', NotificationSchema)