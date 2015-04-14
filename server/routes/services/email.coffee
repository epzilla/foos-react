nodemailer = require 'nodemailer'
Player = require '../../models/player'
Notification = require '../../models/notification'
conf = require '../../conf/config'
env = conf.ENVIRONMENT
address = conf.ADDRESS

fullAddress = if (env is 'prod' or env is 'production') then address else (address + ':' + conf.PORT)

transporter = nodemailer.createTransport(
  service: 'gmail'
  auth:
    user: 'snappyfoos@gmail.com'
    pass: '$ynapsef00sb@ll')

module.exports =

  sendStartMatchEmail: (players, passcode) ->
    players.forEach (player) ->
      if player.email and player.email isnt ''
        firstName = player.name.split(' ')[0]

        textString = 'You can click here for the score correction page, ' +
          'though we hope you won\'t need it! ' +
          '<a href="' + fullAddress + '/scoreCorrection?code=' + passcode + '">' + fullAddress +
          '/scoreCorrection?code=' + passcode + '</a>'

        transporter.sendMail
          from: 'snappyfoos@gmail.com'
          to: player.email
          subject: firstName + ', Your Foosball Match Is Underway!'
          html: textString

  createNotificationByEmailAddress: (req, res) ->
    Notification.findOne {email: req.body.email}, (err, notification) ->
      if err
        res.status(500).send err
        return

      if not notification
        note = new Notification(
          email: req.body.email
        )

        note.save (err, newNote) ->
          if err
            res.status(500).send err

          res.json newNote
          return
      else
        res.sendStatus 400
        return
    return

  createNotificationByPlayerId: (req, res) ->
    Player.findById req.body.id, (err, player) ->
      if err
        res.status(500).send err

      if player
        Notification.findOne {email: player.email}, (err, notification) ->
          if err
            res.status(500).send err

          if not notification
            note = new Notification(
              email: req.params.email
            )
            note = new Notification(
              email: player.email
            )

            note.save (err, newNote) ->
              if err
                res.status(500).send err

              res.sendStatus 200
          else
            res.sendStatus 400
      else
        res.sendStatus 400

  fireNotifications: ->
    Notification.find (err, notes) ->
      notes.forEach (note) ->
        transporter.sendMail
          from: 'snappyfoos@gmail.com'
          to: note.email
          subject: 'The Foosball Table Is Open!'
          text: 'Better get while the gettin\'s good!'

      Notification.find().remove().exec()
