qwest = require 'qwest'

module.exports =

  get: (url) ->
    qwest.get(url, null, {responseType: 'json'})

  post: (url, data) ->
    qwest.post(url, data, {dataType: 'json', responseType: 'json'})

  put: (url, data) ->
    qwest.put(url, data, {dataType: 'json', responseType: 'json'})