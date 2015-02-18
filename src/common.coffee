setDragImage = require "./utilities/set_drag_image"
isString = require "./utilities/is_string"
config = require "./utilities/config"

class DragAndDrop
  iconAndSize: null

  _typesForEvent: (e) ->
    if value = config("activeDragAndDropTypes")
      value
    else
      e.dataTransfer.types[..]

  _addElementsForEvent: (e) ->
    if @options.addElements
      elements = @options.addElements e, e.dataTransfer, @_elements[0]
      @_elements = elements

  _shouldAccept: (e) ->
    if @options.accepts
      types = @_typesForEvent(e.originalEvent)
      value = @options.accepts(types, e)
      if isString(value)
        value in types
      else
        value
    else
      true

  _setupDragImage: (e) ->
    if @options.iconAndSize
      dataTransfer = e.dataTransfer
      @iconAndSize = @options.iconAndSize(@_elements, dataTransfer, e)
      setDragImage(e, @iconAndSize)

module.exports = DragAndDrop
