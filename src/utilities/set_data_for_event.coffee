isString = require "./is_string"
config = require "./config"

module.exports = (context, e) ->
  keys = []

  supportsCustomTypes = try
    e.dataTransfer.setData("test/com.metalabdesign.dnd", "success")
    e.dataTransfer.clearData("test/com.metalabdesign.dnd")
    true
  catch error
    false

  if supportsCustomTypes
    for key, value of context
      value = if isString(value) then value else JSON.stringify(value)
      e.dataTransfer.setData(key, value)
  else
    keys = for key, value of context
      key

    config("activeDragAndDropTypes", keys)

    if URL = context.URL
      e.dataTransfer.setData "URL", URL

    e.dataTransfer.setData "Text", JSON.stringify(context)
