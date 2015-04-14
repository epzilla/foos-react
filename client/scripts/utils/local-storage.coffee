conf = require '../../../conf/config'

module.exports =

  prefix: conf.LOCAL_STORAGE_PREFIX or ''

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