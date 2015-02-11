config = require "./config"

module.exports = (dataTransfer) ->
  if value = config("activeDragAndDropTypes")
    value
  else if dataTransfer?.types
    dataTransfer.types[..]
  else
    []
