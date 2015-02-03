module.exports = (value) ->
  Object::toString.call(value) == "[object String]"
