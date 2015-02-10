setDragImage = require "./utilities/set_drag_image"
isString = require "./utilities/is_string"
typesForDataTransfer = require "./utilities/types_for_data_transfer"

class DragAndDrop
  iconAndSize: null

  _addElementsForEvent: (e) ->
    if @options.addElements
      @_elements = @options.addElements e, e.dataTransfer, @_elements[0]

  _shouldAccept: (e) ->
    if @options.accepts
      types = typesForDataTransfer(e.originalEvent.dataTransfer)
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
