DragAndDrop = require("./common")
SortableSession = require "./sortable_session"

config = require "./utilities/config"
cursorInsideElement = require "./utilities/cursor_inside_element"
dataFromEvent = require "./utilities/data_from_event"
defaults = require "./utilities/defaults"
setDataForEvent = require "./utilities/set_data_for_event"
typesForDataTransfer = require "./utilities/types_for_data_transfer"
normalizeEventCallback = require "./utilities/normalize_event_callback"

class Sortable extends DragAndDrop
  isBound: false
  enabled: false
  placeholder: null

  constructor: (@el, options = {}) ->
    @_elements = [] # TODO just use the session
    @$el = $(@el) # TODO redundent when creating a event binding module

    if options.items
      options.itemSelector = options.items
      console.warn("Sortable's `items` option is now `itemSelector`, but it will still work for now")

    @options = defaults(options, {
      manual: false
      tolerance: 12
      itemSelector: "[draggable='true']"
      direction: "vertical"
      placeholder: (e, index) ->
        element = document.createElement("li")
        element.className = "placeholder"
        element
    })

    @enable()

  enable: ->
    unless @enabled
      @$el.on "dragstart", @options.itemSelector, $.proxy(this, "_handleDragstart")
      @$el.on "dragover", $.proxy(this, "_handleDragover")
      @enabled = true

  disable: ->
    if @enabled
      @$el.off "dragstart", @options.itemSelector, @_handleDragstart
      @$el.off "dragover", @_handleDragover
      @enabled = false
      $(@placeholder).detach() if @placeholder

  #
  # Private
  #

  _handleDrop: normalizeEventCallback (event, dataTransfer) ->
    event.preventDefault()
    event.stopPropagation()
    if @placeholder?.parentNode
      $elements = $(@_elements)

      data = dataFromEvent(dataTransfer)
      data.originalIndex = {
        start: $elements.first().index()
        end: $elements.last().index()
      }

      unless @options.manual
        $elements.detach()

      $placeholder = $(@placeholder)
      _droppedElement = $placeholder.parent()[0]
      _index = $placeholder.index()

      # If @options.manual is true we didn't detach original elements,
      # so placeholder will be off by elements.length when being dragged
      # "down" beneath the elements.
      if @options.manual && _index > data.originalIndex.start
        for element in $elements when @el.contains(element)
          _index -= 1
          _indexAdjusted = true

      # If were moving the elements "up", then the placeholder would be above where the
      # elements came from, so we'll need to -1 from the originalIndex indices.

      if _index < data.originalIndex.start
        data.originalIndex.start -= 1
        data.originalIndex.end -= 1

      # TODO use a document fragment
      unless @options.manual
        $placeholder.after($elements)

      $placeholder.detach()

      @options.sort?.call(this, _index, data, @_elements, _droppedElement, _indexAdjusted)
      @options.stop?.call(this, @_elements)

  _handleDragend: normalizeEventCallback (e) ->
    # HACK need a better way of getting DnD events to propagate properly
    # TODO remove, Flow specific behaviour
    $(document.body).trigger("drag:end", e)

    if @_elements.length
      @options.stop?(@_elements)
      $(@placeholder).detach()
      @placeholder = null

    @_elements = []
    @_cleanUp()

  _boot: ->
    unless @isBound
      @$el.on "drop", $.proxy(this, "_handleDrop")
      @$el.on "dragleave", $.proxy(this, "_handleDragleave")
      @isBound = true

  _cleanUp: ->
    @$el.off "drop", @_handleDrop
    @$el.off "dragend", @_handleDragend
    @$el.off "dragleave", @_handleDragleave
    @isBound = false

  _handleDragleave: normalizeEventCallback (event, dataTransfer) ->
    if cursorInsideElement(event.originalEvent, event.currentTarget)
      $(@placeholder).detach()
      @placeholder = null

    if cursorInsideElement(event.originalEvent, @el)
      @options.out?(event, event.currentTarget, typesForDataTransfer(dataTransfer))

  _handleDragstart: normalizeEventCallback (event, dataTransfer) ->
    # Certain elements within the target elements can actually trigger a drag - like links with HREF attributes
    if @_elementMatchesItemSelector(event.target)
      draggedElement = event.target
    else if element = @_parentOfElementThatMatchesItemSelector(event.target)
      draggedElement = element

    return if !draggedElement

    dataTransfer?.effectAllowed = "move"

    @$el.on("dragend", $.proxy(this, "_handleDragend"))
    @_elements = [draggedElement]

    @_addElementsForEvent(event, dataTransfer)

    activeSession = new SortableSession(@_elements)
    config("activeSession", activeSession)
    context = @options.context?(@_elements, event.currentTarget, dataTransfer) || {}
    context[activeSession.identifier] = true
    setDataForEvent(context, dataTransfer)

    @_setupDragImage(event, dataTransfer)
    @options.start?(@_elements)
    event.stopPropagation()

  _handleDragover: normalizeEventCallback (event, dataTransfer) ->
    if @_shouldAccept(event, dataTransfer)
      event.preventDefault()

      eventTarget = event.target

      # This is awkward but it is important to bind the event to the root el
      # without any selector filtering so you can drop on a header or a footer
      if @_elementMatchesItemSelector(eventTarget)
        draggedOver = eventTarget
      else if element = @_parentOfElementThatMatchesItemSelector(eventTarget)
        draggedOver = element

      if draggedOver && draggedOver != @placeholder
        directionals = if @options.direction == "vertical"
          {
            before: "top"
            after: "bottom"
            clientPosition: event.originalEvent.clientY
          }
        else if @options.direction == "horizontal"
          {
            before: "left"
            after: "right"
            clientPosition: event.originalEvent.clientX
          }

        rect = draggedOver.getBoundingClientRect()

        position = draggedOver.compareDocumentPosition(@placeholder) if @placeholder
        if !@placeholder || position & Node.DOCUMENT_POSITION_DISCONNECTED
          if (rect[directionals.before] - directionals.clientPosition + @options.tolerance) >= 0
            @_flip(event, draggedOver, dataTransfer, "before")
          else if (rect[directionals.after] - directionals.clientPosition - @options.tolerance) <= 0
            @_flip(event, draggedOver, dataTransfer, "after")
        else if position & Node.DOCUMENT_POSITION_FOLLOWING
          if (rect[directionals.before] - directionals.clientPosition + @options.tolerance) >= 0
            @_flip(event, draggedOver, dataTransfer, "before")
        else if position & Node.DOCUMENT_POSITION_PRECEDING
          if (rect[directionals.after] - directionals.clientPosition - @options.tolerance) <= 0
            @_flip(event, draggedOver, dataTransfer, "after")

  _flip: (event, element, dataTransfer, keyword, options = {}) ->
    @_boot()

    @options.over?(event, element, typesForDataTransfer(dataTransfer))

    if !@placeholder
      @placeholder = @options.placeholder(event, @_elements.length)
      $(@placeholder).on("drop", $.proxy(this, "_handleDrop"))
      $(@placeholder).on "dragover", (e) ->
        event.preventDefault()
    else
      $(@placeholder).detach()

    $(element)[keyword](@placeholder)

    if config("activeSession")?.valid(dataTransfer)
      session = config("activeSession")

    @options.insertPlaceholder?(@placeholder, @_elements, session)
    event.stopPropagation()

  _elementMatchesItemSelector: (element) ->
    !!$(element).filter(@options.itemSelector).length

  _parentOfElementThatMatchesItemSelector: (element) ->
    contender = $(element).closest(@options.itemSelector)[0]

    if contender != @el && @el.contains(contender)
      return contender
    else
      return null

module.exports = Sortable
