defaults = require "./utilities/defaults"
setDataForEvent = require "./utilities/set_data_for_event"
DragAndDrop = require "./common"

class Draggable extends DragAndDrop
  constructor: (@el, options) ->
    @_elements = []
    @$el = $(@el)
    @options = defaults(options, {
      selector: null
    })
    @enable()

  enable: ->
    unless @enabled
      @$el.on "dragstart", @options.selector, $.proxy(this, "_dragStart")
      @enabled = true

  disable: ->
    if @enabled
      @$el.off "dragstart", @options.selector, @_dragStart
      @enabled = false

  #
  # Private
  #

  _dragEvent: (e) ->
    @options.drag?(@_elements, e.originalEvent)

  _dragEndEvent: (e) ->
    @options.stop?(@_elements, e.originalEvent)

    @$el.off "drag", @options.selector, @_dragEvent
    @$el.off "dragend", @options.selector, @_dragEndEvent

  _dragStart: (e) ->
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer?.effectAllowed = "move"

    @_elements = [e.currentTarget]
    @_addElementsForEvent e.originalEvent

    if @options.context
      context = @options.context(@_elements, e.currentTarget, dataTransfer)
      setDataForEvent(context, e.originalEvent)

    @_setupDragImage(e.originalEvent)

    @$el.on("drag", @options.selector, $.proxy(this, "_dragEvent")) if @options.drag
    @$el.on("dragend", @options.selector, $.proxy(this, "_dragEndEvent"))

    @options.start?(@_elements)

module.exports = Draggable
