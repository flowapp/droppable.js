DragAndDrop = require("./common")
defaults = require "./utilities/defaults"
cursorInsideElement = require "./utilities/cursor_inside_element"
setDataForEvent = require "./utilities/set_data_for_event"
dataFromEvent = require "./utilities/data_from_event"
SortableSession = require "./sortable_session"

class Sortable extends DragAndDrop
  isBound: false
  enabled: false
  placeholder: null

  constructor: (@el, options = {}) ->
    @_elements = []
    @$el = $(@el)
    @options = defaults(options, {
      "skipRender": false
      manual: false
      "tolerance": 12
      "items": "[draggable='true']"
      "direction": "vertical"
      "placeholder": (e, index) ->
        element = document.createElement("li")
        element.className = "placeholder"
        element
    })

    @enable()

  enable: ->
    unless @enabled
      @$el.on "dragstart", @options.items, $.proxy(this, "_dragstartEvent")
      @$el.on "dragover", @options.items, $.proxy(this, "_dragoverEvent")
      @enabled = true

  disable: ->
    if @enabled
      @$el.off "dragstart", @options.selector, @_dragStart
      @$el.off "dragover", @options.items, @_dragoverEvent
      @enabled = false
      $(@placeholder).detach() if @placeholder

  #
  # Private
  #

  _dropEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()

    return if !@placeholder?.parentNode

    $elements = $ @_elements

    data = dataFromEvent(e.originalEvent)
    data.originalIndex = {
      start: $elements.first().index()
      end: $elements.last().index()
    }

    if @options.manual == false
      if @options.skipRender
        $elements.remove()
      else
        $elements.detach()

    $placeholder = $ @placeholder
    _index = $placeholder.index()

# If were moving the elements "up", then the placeholder would be above where the
# elements came from, so we'll need to -1 from the originalIndex indices.

    if (_index < data.originalIndex.start)
      data.originalIndex.start -= 1
      data.originalIndex.end -= 1

    # TODO use a document fragment
    if !@options.skipRender && !@options.manual
      $placeholder.after($elements)
    $placeholder.detach()

    @options.sort?.call(this, _index, data, @_elements)
    @options.stop?.call(this, @_elements)

    false

  _dragendEvent: (e) ->
    # HACK need a better way of getting DnD events to propagate properly
    $("body").trigger("drag:end", e)

    if @_elements.length
      @options.stop @_elements if @options.stop
      $(@placeholder).detach()
      @placeholder = null

    @_elements = []
    @_cleanUp()

  _boot: ->
    unless @isBound
      @$el.on "drop", @options.items, $.proxy(this, "_dropEvent")
      @$el.on "dragleave", $.proxy(this, "_dragleave")
      @isBound = true

  _cleanUp: ->
    @$el.off "drop", @options.items, @_dropEvent
    @$el.off "dragend", @options.items, @_dragendEvent
    @$el.off "dragleave", @_dragleave
    @isBound = false

  _dragleave: (e) ->
    if cursorInsideElement(e.originalEvent, e.currentTarget)
      $(@placeholder).detach()
      @placeholder = null

    if cursorInsideElement(e.originalEvent, @el)
      @options.out(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.out

  _dragstartEvent: (e) ->
    $currentTarget = $ e.currentTarget
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer.effectAllowed = "move" if dataTransfer

    @$el.on("dragend", @options.items, $.proxy(this, "_dragendEvent"))

    @_elements = [e.currentTarget]
    @_addElementsForEvent(e.originalEvent)

    activeSession = new SortableSession(@_elements)
    config("activeSession", keys)
    context = @options.context?(@_elements, e.currentTarget, dataTransfer) || {}
    context[activeSession.identifier] = true
    setDataForEvent(context, e.originalEvent)

    @_setupDragImage(e.originalEvent)
    @options.start?(@_elements)
    e.stopPropagation()

  _dragoverEvent: (e) ->
    e.preventDefault()
    placeholderIndex = $(@placeholder).index()
    targetIndex = $(e.currentTarget).index()

    x = e.originalEvent.clientX
    y = e.originalEvent.clientY

    directionals = if @options.direction == "vertical"
      {
        before: "top"
        after: "bottom"
        clientPosition: y
      }
    else if @options.direction == "horizontal"
      {
        before: "left"
        after: "right"
        clientPosition: x
      }

    rect = e.currentTarget.getBoundingClientRect()

    return if placeholderIndex == targetIndex
    if placeholderIndex == -1
      if (rect[directionals.before] - directionals.clientPosition + @options.tolerance) >= 0
        @_flip(e, "before")
      else if (rect[directionals.after] - directionals.clientPosition - @options.tolerance) <= 0
        @_flip(e, "after")
      return

    if placeholderIndex > targetIndex
      if (rect[directionals.before] - directionals.clientPosition + @options.tolerance) >= 0
        @_flip(e, "before")
    else
      if (rect[directionals.after] - directionals.clientPosition - @options.tolerance) <= 0
        @_flip(e, "after")

    return

  _flip: (e, keyword) ->
    return if e.currentTarget == @placeholder

    nativeEvent = e.originalEvent || e
    return if !@_shouldAccept e
    @_boot()

    @options.over(e, e.currentTarget, @_typesForEvent(e.originalEvent)) if @options.over

    unless @placeholder
      @placeholder = @options.placeholder(e, @_elements.length)
      $(@placeholder).on("drop", $.proxy(this, "_dropEvent"))
    $(@placeholder).detach()
    $(e.currentTarget)[keyword](@placeholder)

    if config("activeSession")?.valid(e.originalEvent)
      session = activeSession

    @options.insertPlaceholder?(@placeholder, @_elements, session)
    e.stopPropagation()

module.exports = Sortable
