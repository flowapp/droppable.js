defaults = require "./utilities/defaults"
setDataForEvent = require "./utilities/set_data_for_event"
DragAndDrop = require "./common"

class Draggable extends DragAndDrop
  constructor: (@el, options = {}) ->
    @_elements = []
    @$el = $(@el)
    @options = defaults(options, {
      selector: null
    })
    @enable()

  enable: ->
    unless @enabled
      @$el.on "dragstart", @options.selector, $.proxy(this, "_handleDragstart")
      @enabled = true

  disable: ->
    if @enabled
      @$el.off "dragstart", @options.selector, @_handleDragstart
      @enabled = false

  #
  # Private
  #

  _handleDrag: (e) ->
    @options.drag?(@_elements, e.originalEvent)

  _handleDragend: (e) ->
    @options.stop?(@_elements, e.originalEvent)

    @$el.off "drag", @options.selector, @_handleDrag
    @$el.off "dragend", @options.selector, @_handleDragend

  _handleDragstart: (e) ->
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer?.effectAllowed = "move"

    @_elements = [e.currentTarget]
    @_addElementsForEvent e.originalEvent

    if @options.context
      context = @options.context(@_elements, e.currentTarget, dataTransfer)
      setDataForEvent(context, e.originalEvent)

    @_setupDragImage(e.originalEvent)

    @$el.on("drag", @options.selector, $.proxy(this, "_handleDrag")) if @options.drag
    @$el.on("dragend", @options.selector, $.proxy(this, "_handleDragend"))

    @options.start?(@_elements)

module.exports = Draggable
