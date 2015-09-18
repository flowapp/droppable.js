DragAndDrop = require "./common"

config = require "./utilities/config"
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
    @$el.off "dragover", @options.selector, @_handleDragover
    @isBound = false

  _handleDragenter: normalizeEventCallback (e, dataTransfer) ->
    if @_shouldAccept(e, dataTransfer)
      e.stopPropagation()
      @_cleanUp()
      $(e.currentTarget).addClass(@options.hoverClass) if @options.hoverClass
      @options.over?(e, e.currentTarget, typesForDataTransfer(dataTransfer))
      unless @isBound
        @$el.on "drop", @options.selector, $.proxy(this, "_handleDrop")
        @$el.on "dragleave", @options.selector, $.proxy(this, "_handleDragleave")
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

  _handleDragleave: normalizeEventCallback (e, dataTransfer) ->
    $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
    @options.out?(e, e.currentTarget, typesForDataTransfer(dataTransfer))
    @_cleanUp()
    e.stopPropagation()
    e.preventDefault()

  _handleDragover: normalizeEventCallback (e) ->
    @options.dragOver?(e, e.currentTarget)
    e.preventDefault()

module.exports = Droppable
