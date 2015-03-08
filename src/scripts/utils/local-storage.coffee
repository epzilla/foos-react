conf = require './config'

module.exports =

  prefix: conf.localStoragePrefix or ''

  get: (key) ->
    self = this
    prefixedKey = self.prefix.concat('-', key)
    JSON.parse window.localStorage.getItem prefixedKey

  set: (key, val) ->
    self = this
    prefixedKey = self.prefix.concat('-', key)
    value = JSON.stringify(val)
    window.localStorage.setItem prefixedKey, value
    value