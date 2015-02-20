config = require "./config"

module.exports = (dataTransfer) ->
  if value = config("activeDragAndDropTypes")
    value
  else if dataTransfer?.types
    # Can’t use slice as it’s not an array, it’s actually a “DOMStringList”
    [].slice.call(dataTransfer.types, 0)
  else
    []
