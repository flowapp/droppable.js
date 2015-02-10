defaults = require "./utilities/defaults"
cursorInsideElement = require "./utilities/cursor_inside_element"
dataFromEvent = require "./utilities/data_from_event"
config = require "./utilities/config"
DragAndDrop = require "./common"
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
      @$el.on "dragenter", @options.selector, $.proxy(this, "_dragenter")

  disable: ->
    @_cleanUp()
    @$el.off "dragenter", @options.selector, @_dragenter
    @enabled = false

  destroy: ->
    @disable()

  #
  # Private
  #

  _cleanUp: ->
    @$el.off "drop", @options.selector, @_dropEvent
    @$el.off "dragleave", @options.selector, @_dragleave
    @$el.off "dragover", @options.selector, @_dragover
    @isBound = false

  _dragenter: (e) ->
    nativeEvent = e.originalEvent || e
    if @_shouldAccept(e)
      e.stopPropagation()
      $(e.currentTarget).addClass(@options.hoverClass) if @options.hoverClass
      @options.over?(e, e.currentTarget, typesForDataTransfer(e.originalEvent.dataTransfer))
      unless @isBound
        @$el.on "drop", @options.selector, $.proxy(this, "_dropEvent")
        @$el.on "dragleave", @options.selector, $.proxy(this, "_dragleave")
        @$el.on "dragover", @options.selector, $.proxy(this, "_dragover")
        @isBound = true

  _dropEvent: (e) ->
    if @options.drop
      @options.drop(e, dataFromEvent(e.originalEvent))
      e.stopPropagation()
      e.preventDefault()

    $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass

    # HACK Need a better way of getting DnD events to propagate properly
    # TODO remove, Flow specific behaviour
    $(document.body).trigger("drag:end", e)

    @_cleanUp()
    undefined

  _dragleave: (e) ->
    # HACK some UA fires drag leave too often, we need to make sure it’s
    # actually outside of the element. There is probably better ways to check
    # this as it’s covering every case.
    if cursorInsideElement(e.originalEvent, e.currentTarget)
      $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
      @options.out?(e, e.currentTarget, typesForDataTransfer(e.originalEvent.dataTransfer))

    if cursorInsideElement(e.originalEvent, @el)
      @_cleanUp()

    e.stopPropagation()
    e.preventDefault() # Figure out if this is needed

  _dragover: (e) ->
    @options.dragOver?(e, e.currentTarget)
    e.preventDefault()
    undefined

module.exports = Droppable
