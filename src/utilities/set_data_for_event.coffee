isString = require "./is_string"
config = require "./config"

module.exports = (context, dataTransfer) ->
  keys = []

  supportsCustomTypes = try
    dataTransfer.setData("test/com.getflow.dnd", "success")
    dataTransfer.clearData("test/com.getflow.dnd")
    true
  catch error
    false

  if supportsCustomTypes
    for key, value of context
      value = if isString(value) then value else JSON.stringify(value)
      dataTransfer.setData(key, value)
  else
    keys = for key, value of context
      key

    config("activeDragAndDropTypes", keys)

    if URL = context.URL
      dataTransfer.setData "URL", URL

    dataTransfer.setData "Text", JSON.stringify(context)
