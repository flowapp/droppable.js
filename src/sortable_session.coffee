config = require "./utilities/config"

class SortableSession
  constructor: (@_elements) ->
    @identifier = "#{~~((1+Math.random())*0x10000)}/com.getflow.session"
    @rects = for element in @_elements
      element.getBoundingClientRect()

  size: ->
    @rects[0]

  valid: (dataTransfer) ->
    source = config("activeDragAndDropTypes") || dataTransfer.types
    @identifier in source

module.exports = SortableSession
