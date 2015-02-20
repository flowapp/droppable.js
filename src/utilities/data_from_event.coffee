config = require "./config"

module.exports = (dataTransfer) ->
  if config("activeDragAndDropTypes")
    value = dataTransfer.getData("Text")
    data = try
      JSON.parse value
    catch error
      value

    data
  else
    data = {}
    for type in dataTransfer.types
      try
        value = dataTransfer.getData(type)
      catch error
        if type == "Files"
          value = dataTransfer.files # IE workaround

      data[type] = try
        JSON.parse value
      catch error
        value

    data
