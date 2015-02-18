dispatchDragEvent = require("./helpers/dispatch_drag_event")
Draggable = require("droppable").Draggable

describe "Draggable", ->
  set "options", -> {}
  beforeEach ->
    @el = document.createElement("div")
    document.body.appendChild(@el)
    @draggable = new Draggable(@el, @options)

  afterEach ->
    document.body.removeChild(@el)

  describe "`dragstart` event", ->
    beforeEach ->
      {@event} = dispatchDragEvent(@el, "dragstart")

    describe "options.start", ->
      set "options", -> {start: jasmine.createSpy("start")}
      it "fires `options.start`", ->
        expect(@options.start).toHaveBeenCalledWith([@el])

    describe "options.context", ->
      set "options", ->
        { context: jasmine.createSpy("context").and.returnValue({name: "Walter White" }) }

      it "calls `options.context`", ->
        expect(@options.context).toHaveBeenCalledWith([@el], @el, @event.dataTransfer)

      it "sets its return data onto dataTransfer object", ->
        expect(@event.dataTransfer.getData("name")).toEqual("Walter White")

    describe "options.iconAndSize", ->
      set "options", ->
        { iconAndSize: jasmine.createSpy("iconAndSize").and.returnValue([null, 0, 0]) }

      it "calls `options.iconAndSize`", ->
        expect(@options.iconAndSize).toHaveBeenCalled()

    describe "options.addElements", ->
      set "options", ->
        {
          start: jasmine.createSpy("start")
          context: jasmine.createSpy("context")
          addElements: jasmine.createSpy("addElements").and.returnValue([@el, document.createElement("div")])
        }

      it "calls `options.addElements`", ->
        expect(@options.addElements).toHaveBeenCalled()

      it "calls `options.start` with update elements", ->
        expect(@options.start).toHaveBeenCalledWith(@options.addElements())

      it "calls `options.context` with update elements", ->
        expect(@options.context).toHaveBeenCalledWith(@options.addElements(), @el, @event.dataTransfer)

  describe "drag", ->
    beforeEach ->
      dispatchDragEvent(@el, "dragstart")
      {event: @dragEvent} = dispatchDragEvent(@el, "drag")

    describe "`options.drag`", ->
      set "options", -> {drag: jasmine.createSpy("drag")}
      it "calls `options.drag`", ->
        expect(@options.drag).toHaveBeenCalledWith([@el], @dragEvent)

  describe "stop", ->
    set "options", -> {stop: jasmine.createSpy("stop")}
    beforeEach ->
      dispatchDragEvent(@el, "dragstart")
      {event: @dragendEvent} = dispatchDragEvent(@el, "dragend")

    it "calls `options.stop`", ->
      expect(@options.stop).toHaveBeenCalledWith([@el], @dragendEvent)

  describe "#disable", ->
    set "options", -> {start: jasmine.createSpy("start")}
    beforeEach ->
      @draggable.disable()
      {@event} = dispatchDragEvent(@el, "dragstart")

    it "disables when calling #disable", ->
      expect(@options.start).not.toHaveBeenCalled()

  describe "#enable", ->
    set "options", -> {start: jasmine.createSpy("dragstart")}
    beforeEach ->
      @draggable.disable()
      @draggable.enable()
      {@event} = dispatchDragEvent(@el, "dragstart")

    it "calls `#enable` enables it", ->
      expect(@options.start).toHaveBeenCalled()
