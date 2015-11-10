DragAndDrop = require "./common"

config = require "./utilities/config"
cursorInsideElement = require "./utilities/cursor_inside_element"
dataFromEvent = require "./utilities/data_from_event"
defaults = require "./utilities/defaults"
normalizeEventCallback = require "./utilities/normalize_event_callback"
typesForDataTransfer = require "./utilities/types_for_data_transfer"

class Droppable extends DragAndDrop
  isBound: false
  enabled: false
  constructor: (@el, options = {}) ->
    @$el = $(@el)
    @options = defaults(options, {
      selector: null
    })

    @enable()

  enable: ->
    unless @enabled
      @enabled = true
      @$el.on "dragenter", @options.selector, $.proxy(this, "_handleDragenter")

  disable: ->
    @_cleanUp()
    @$el.off "dragenter", @options.selector, @_handleDragenter
    @enabled = false

  destroy: ->
    @disable()

  #
  # Private
  #

  _cleanUp: ->
    @$el.off "drop", @options.selector, @_handleDrop
    @$el.off "dragleave", @options.selector, @_handleDragleave
    $(window).off "mouseout", @_handleWindowMouseout
    @$el.off "dragover", @options.selector, @_handleDragover
    @isBound = false

  _handleDragenter: normalizeEventCallback (e, dataTransfer) ->
    if @_shouldAccept(e, dataTransfer)
      e.stopPropagation()
      $(e.currentTarget).addClass(@options.hoverClass) if @options.hoverClass
      @options.over?(e, e.currentTarget, typesForDataTransfer(dataTransfer))
      unless @isBound
        @$el.on "drop", @options.selector, $.proxy(this, "_handleDrop")
        @$el.on "dragleave", @options.selector, $.proxy(this, "_handleDragleave")
        $(window).on "mouseout", $.proxy(this, "_handleWindowMouseout")
        @$el.on "dragover", @options.selector, $.proxy(this, "_handleDragover")
        @isBound = true

  _handleDrop: normalizeEventCallback (e, dataTransfer) ->
    if @options.drop
      @options.drop(e, dataFromEvent(dataTransfer))
      e.stopPropagation()
      e.preventDefault()

    $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass

    # HACK Need a better way of getting DnD events to propagate properly
    # TODO remove, Flow specific behaviour
    $(document.body).trigger("drag:end", e)

    @_cleanUp()

  _handleWindowMouseout: normalizeEventCallback (e, dataTransfer) ->
    $(@el).removeClass(@options.hoverClass) if @options.hoverClass
    @options.out?(e, @el, typesForDataTransfer(dataTransfer))
    @_cleanUp()

  _handleDragleave: normalizeEventCallback (e, dataTransfer) ->
    # HACK some UA fires drag leave too often, we need to make sure it’s
    # actually outside of the element. There is probably better ways to check
    # this as it’s covering every case.
    if cursorInsideElement(e.originalEvent, e.currentTarget)
      $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
      @options.out?(e, e.currentTarget, typesForDataTransfer(dataTransfer))

    if cursorInsideElement(e.originalEvent, @el)
      @_cleanUp()

    e.stopPropagation()
    e.preventDefault() # Figure out if this is needed

  _handleDragover: normalizeEventCallback (e) ->
    @options.dragOver?(e, e.currentTarget)
    e.preventDefault()

module.exports = Droppable
