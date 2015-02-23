setDragImage = require "./utilities/set_drag_image"
isString = require "./utilities/is_string"
typesForDataTransfer = require "./utilities/types_for_data_transfer"

class DragAndDrop
  iconAndSize: null

  _addElementsForEvent: (e, dataTransfer) ->
    if @options.addElements
      @_elements = @options.addElements(e, dataTransfer, @_elements[0])

  _shouldAccept: (e, dataTransfer) ->
    if @options.accepts
      types = typesForDataTransfer(dataTransfer)
      value = @options.accepts(types, e)
      if isString(value)
        value in types
      else
        value
    else
      true

  _setupDragImage: (e, dataTransfer) ->
    if @options.iconAndSize
      @iconAndSize = @options.iconAndSize(@_elements, dataTransfer, e)
      setDragImage(e, dataTransfer, @iconAndSize)

module.exports = DragAndDrop
