DragAndDrop = require "./common"

defaults = require "./utilities/defaults"
normalizeEventCallback = require "./utilities/normalize_event_callback"
setDataForEvent = require "./utilities/set_data_for_event"

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

  _handleDrag: normalizeEventCallback (e) ->
    @options.drag?(@_elements, e.originalEvent)

  _handleDragend: normalizeEventCallback (e) ->
    @options.stop?(@_elements, e.originalEvent)

    @$el.off "drag", @options.selector, @_handleDrag
    @$el.off "dragend", @options.selector, @_handleDragend

  _handleDragstart: normalizeEventCallback (e, dataTransfer) ->
    dataTransfer?.effectAllowed = "move"

    @_elements = [e.currentTarget]
    @_addElementsForEvent(e, dataTransfer)

    if @options.context
      context = @options.context(@_elements, e.currentTarget, dataTransfer)
      setDataForEvent(context, dataTransfer)

    @_setupDragImage(e, dataTransfer)

    @$el.on("drag", @options.selector, $.proxy(this, "_handleDrag")) if @options.drag
    @$el.on("dragend", @options.selector, $.proxy(this, "_handleDragend"))

    @options.start?(@_elements, e)

module.exports = Draggable
