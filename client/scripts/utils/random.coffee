module.exports =

  getRandomNum: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  getRandomToken: (length) ->
    Math.random().toString(36).substring(2, length + 2)