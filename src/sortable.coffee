DragAndDrop = require("./common")
defaults = require "./utilities/defaults"
cursorInsideElement = require "./utilities/cursor_inside_element"
setDataForEvent = require "./utilities/set_data_for_event"
dataFromEvent = require "./utilities/data_from_event"
SortableSession = require "./sortable_session"
config = require "./utilities/config"
typesForDataTransfer = require "./utilities/types_for_data_transfer"

class Sortable extends DragAndDrop
  isBound: false
  enabled: false
  placeholder: null

  constructor: (@el, options = {}) ->
    @_elements = [] # TODO just use the session
    @$el = $(@el) # TODO redundent when creating a event binding module
    @options = defaults(options, {
      manual: false
      tolerance: 12
      items: "[draggable='true']"
      direction: "vertical"
      placeholder: (e, index) ->
        element = document.createElement("li")
        element.className = "placeholder"
        element
    })

    @enable()

  enable: ->
    unless @enabled
      @$el.on "dragstart", @options.items, $.proxy(this, "_handleDragstart")
      @$el.on "dragover", @options.items, $.proxy(this, "_handleDragover")
      @enabled = true

  disable: ->
    if @enabled
      @$el.off "dragstart", @options.items, @_handleDragstart
      @$el.off "dragover", @options.items, @_handleDragover
      @enabled = false
      $(@placeholder).detach() if @placeholder

  #
  # Private
  #

  _handleDrop: (e) ->
    e.preventDefault()
    e.stopPropagation()
    if @placeholder?.parentNode
      $elements = $(@_elements)

      data = dataFromEvent(e.originalEvent)
      data.originalIndex = {
        start: $elements.first().index()
        end: $elements.last().index()
      }

      unless @options.manual
        $elements.detach()

      $placeholder = $(@placeholder)
      _index = $placeholder.index()

      # If were moving the elements "up", then the placeholder would be above where the
      # elements came from, so we'll need to -1 from the originalIndex indices.

      if _index < data.originalIndex.start
        data.originalIndex.start -= 1
        data.originalIndex.end -= 1

      # TODO use a document fragment
      unless @options.manual
        $placeholder.after($elements)

      $placeholder.detach()

      @options.sort?.call(this, _index, data, @_elements)
      @options.stop?.call(this, @_elements)

    undefined

  _handleDragend: (e) ->
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
      @$el.on "drop", @options.items, $.proxy(this, "_handleDrop")
      @$el.on "dragleave", $.proxy(this, "_handleDragleave")
      @isBound = true

  _cleanUp: ->
    @$el.off "drop", @options.items, @_handleDrop
    @$el.off "dragend", @options.items, @_handleDragend
    @$el.off "dragleave", @_handleDragleave
    @isBound = false

  _handleDragleave: (e) ->
    if cursorInsideElement(e.originalEvent, e.currentTarget)
      $(@placeholder).detach()
      @placeholder = null

    if cursorInsideElement(e.originalEvent, @el)
      @options.out?(e, e.currentTarget, typesForDataTransfer(e.originalEvent.dataTransfer))

  _handleDragstart: (e) ->
    $currentTarget = $(e.currentTarget)
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer?.effectAllowed = "move"

    @$el.on("dragend", @options.items, $.proxy(this, "_handleDragend"))

    @_elements = [e.currentTarget]
    @_addElementsForEvent(e.originalEvent)

    activeSession = new SortableSession(@_elements)
    config("activeSession", activeSession)
    context = @options.context?(@_elements, e.currentTarget, dataTransfer) || {}
    context[activeSession.identifier] = true
    setDataForEvent(context, e.originalEvent)

    @_setupDragImage(e.originalEvent)
    @options.start?(@_elements)
    e.stopPropagation()

  _handleDragover: (e) ->
    if @_shouldAccept(e)
      e.preventDefault()
      placeholderIndex = $(@placeholder).index()
      targetIndex = $(e.currentTarget).index()

      if e.currentTarget != @placeholder
        directionals = if @options.direction == "vertical"
          {
            before: "top"
            after: "bottom"
            clientPosition: e.originalEvent.clientY
          }
        else if @options.direction == "horizontal"
          {
            before: "left"
            after: "right"
            clientPosition: e.originalEvent.clientX
          }

        rect = e.currentTarget.getBoundingClientRect()
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

    undefined

  _flip: (e, keyword) ->
    nativeEvent = e.originalEvent || e
    @_boot()

    @options.over?(e, e.currentTarget, typesForDataTransfer(e.originalEvent.dataTransfer))

    unless @placeholder
      @placeholder = @options.placeholder(e, @_elements.length)
      $(@placeholder).on("drop", $.proxy(this, "_handleDrop"))
      $(@placeholder).on "dragover", (e) ->
        e.preventDefault()

    $(@placeholder).detach()
    $(e.currentTarget)[keyword](@placeholder)

    if config("activeSession")?.valid(e.originalEvent)
      session = config("activeSession")

    @options.insertPlaceholder?(@placeholder, @_elements, session)
    e.stopPropagation()

module.exports = Sortable
