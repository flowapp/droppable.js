module.exports = (object, defaults) ->
  for own key, value of defaults when !object.hasOwnProperty(key)
    object[key] = value

  object