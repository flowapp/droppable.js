config = require "./config"

module.exports = (e) ->
  if config("activeDragAndDropTypes")
    value = e.dataTransfer.getData("Text")
    data = try
      JSON.parse value
    catch error
      value

    data
  else
    data = {}
    for type in e.dataTransfer.types
      try
        value = e.dataTransfer.getData(type)
      catch error
        if type == "Files"
          value = e.dataTransfer.files # IE workaround

      data[type] = try
        JSON.parse value
      catch error
        value

    data
