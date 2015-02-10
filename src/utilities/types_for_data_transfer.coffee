config = require "./config"

module.exports = (dataTransfer) ->
  if value = config("activeDragAndDropTypes")
    value
  else
    dataTransfer.types[..]
