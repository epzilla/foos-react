Carrier = require '../../models/carrier'
fs = require 'fs'

module.exports =
  init: ->
    Carrier.count (err, count) ->
      if !err and count is 0
        obj = undefined
        fs.readFile 'conf/carriers.csv', (err, data) ->
          if err
            throw err
          array = data.toString().split('\n')
          carriers = []
          array.forEach (ln) ->
            if ln and ln isnt ''
              lnParts = ln.split(',')
              name = lnParts[0]
              suffix = lnParts[1]
              carriers.push
                'name': name
                'suffix': suffix
          Carrier.collection.insert carriers, (err, carrierList) ->
            if err
              throw err
            console.info 'Seeded list of carriers'

  findAll: (req, res) ->
    Carrier.find (err, carriers) ->
      if err
        res.send err
      res.json carriers
