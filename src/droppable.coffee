defaults = require "./utilities/defaults"
cursorInsideElement = require "./utilities/cursor_inside_element"
dataFromEvent = require "./utilities/data_from_event"
config = require "./utilities/config"
DragAndDrop = require "./common"

class Droppable extends DragAndDrop
  isBound: false
  enabled: false
  constructor: (@el, options = {}) ->
    @$el = $(@el)
    @options = defaults(options, {
      "selector": null
      "greedy": true
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
    return if !@_shouldAccept e

    $(e.currentTarget).addClass(@options.hoverClass) if @options.hoverClass
    @options.over(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.over

    return false if @isBound
    @$el.on "drop", @options.selector, $.proxy(this, "_dropEvent")
    @$el.on "dragleave", @options.selector, $.proxy(this, "_dragleave")
    @$el.on "dragover", @options.selector, $.proxy(this, "_dragover")
    @isBound = true
    false

  _dropEvent: (e) ->
    @options.drop(e, dataFromEvent(e.originalEvent)) if @options.drop
    $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass

    # HACK!!! Need a better way of getting DnD events to propagate properly
    $("body").trigger("drag:end", e)

    @_cleanUp()

    return if !@options.drop # Make it progagate if no drop event is spesified

    e.stopPropagation()
    false

  _dragleave: (e) ->
    # Hack
    if cursorInsideElement(e.originalEvent, e.currentTarget)
      $(e.currentTarget).removeClass(@options.hoverClass) if @options.hoverClass
      @options.out(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.out

    if cursorInsideElement(e.originalEvent, @el)
      @_cleanUp()

    false

  _dragover: (e) ->
    @options.dragOver(e, e.currentTarget) if @options.dragOver
    e.preventDefault()
    true

module.exports = Droppable
