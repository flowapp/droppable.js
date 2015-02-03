cache = {}
module.exports = (key, value) ->
  if value
    cache[key] = value
  else
    cache[key]
