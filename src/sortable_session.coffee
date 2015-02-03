class SortableSession
  constructor: (@_elements) ->
    @identifier = "#{~~((1+Math.random())*0x10000)}/com.getflow.session"
    @rects = for element in @_elements
      element.getBoundingClientRect()

  size: ->
    @rects[0]

  valid: (e) ->
    source = activeDragAndDropTypes || e.dataTransfer.types
    @identifier in source
