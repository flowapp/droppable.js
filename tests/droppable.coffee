dispatchDragEvent = require("./helpers/dispatch_drag_event")
Droppable = require("droppable").Droppable

describe "Droppable", ->
  set "options", -> {}
  beforeEach ->
    @el = document.createElement("div")
    @el.style.width = "210px"
    @el.style.height = "220px"
    @el.style.position = "absolute"
    @el.style.top = "230px"
    @el.style.left = "240px"

    document.body.appendChild(@el)
    @droppable = new Droppable(@el, @options)

  afterEach ->
    document.body.removeChild(@el)

  describe "`options.over`", ->
    set "options", -> {over: jasmine.createSpy("over")}
    it "calls `options.over`", ->
      dispatchDragEvent(@el, "dragenter")
      expect(@options.over).toHaveBeenCalled()

  describe "`options.accepts`", ->
    set "options", ->
      {
        over: jasmine.createSpy("over")
        accepts: =>
          @accepts
      }

    describe "returning strings", ->
      set "accepts", -> "name"
      it "accepts matching types", ->
        dispatchDragEvent(@el, "dragenter", undefined, {name: "Walter White"})
        expect(@options.over).toHaveBeenCalled()

      it "rejects not matching types", ->
        dispatchDragEvent(@el, "dragenter", undefined, {fullName: "Walter White"})
        expect(@options.over).not.toHaveBeenCalled()

    describe "returning non-strings", ->
      beforeEach ->
        dispatchDragEvent(@el, "dragenter")

      describe "returning truthy", ->
        set "accepts", -> true
        it "accepts truthy values", ->
          expect(@options.over).toHaveBeenCalled()

      describe "returning falsy", ->
        set "accepts", -> false
        it "rejects falsy values", ->
          expect(@options.over).not.toHaveBeenCalled()

  describe "`options.dragOver`", ->
    set "options", -> {dragOver: jasmine.createSpy("dragOver")}
    beforeEach ->
      dispatchDragEvent(@el, "dragenter")
      {@event, @defaultPrevented} = dispatchDragEvent(@el, "dragover")

    it "fires `dragOver`", ->
      # TODO fixup, replace jasmine.any with proper event, requires changes to
      # droppable.js to return original event and not jQuery wrapper.
      expect(@options.dragOver).toHaveBeenCalledWith(jasmine.any(Object), @el)

    it "prevents default", ->
      expect(@defaultPrevented).toBeTruthy()

  describe "`dragleave` element", ->
    set "options", ->
      {
        drop: jasmine.createSpy("drop")
        out: jasmine.createSpy("out")
      }

    describe "legit dragleave", ->
      beforeEach ->
        dispatchDragEvent(@el, "dragenter")
        {@defaultPrevented} = dispatchDragEvent(@el, "dragleave")

      it "calls `options.out`", ->
        expect(@options.out).toHaveBeenCalledWith(jasmine.any(Object), @el, [])

      it "prevents default", ->
        expect(@defaultPrevented).toBeTruthy()

      it "cleans up", ->
        dispatchDragEvent(@el, "drop")
        expect(@options.drop).not.toHaveBeenCalled()

    describe "not legit `dragleave`", ->
      beforeEach ->
        dispatchDragEvent(@el, "dragenter")
        {@defaultPrevented} = dispatchDragEvent(@el, "dragleave", {
          clientX: 300
          clientY: 300
          screenX: 300
          screenY: 300
        })

      it "doesn’t call `options.out` if it’s still over it", ->
        expect(@options.out).not.toHaveBeenCalled()

      it "prevents default", ->
        expect(@defaultPrevented).toBeTruthy()

      it "keeps going on", ->
        dispatchDragEvent(@el, "drop")
        expect(@options.drop).toHaveBeenCalled()

  describe "`options.drop`", ->
    set "options", -> {drop: jasmine.createSpy("drop")}
    beforeEach ->
      dispatchDragEvent(@el, "dragenter")
      {@event, @propagationStopped} = dispatchDragEvent(@el, "drop", undefined, {name: "Walter White"})

    it "fires `drop`", ->
      # TODO fixup, replace jasmine.any with proper event, requires changes to
      # droppable.js to return original event and not jQuery wrapper.
      expect(@options.drop).toHaveBeenCalledWith(jasmine.any(Object), {name: "Walter White"})

    it "stops propagation", ->
      expect(@propagationStopped).toBeTruthy()

    describe "without `drop` callback", ->
      set "options", -> {}
      it "doesn’t stop propagation if no drop callback", ->
        expect(@propagationStopped).toBeFalsy()

  describe "`options.hoverClass`", ->
    set "options", -> {hoverClass: "hover"}
    it "adds class on `dragenter`", ->
      dispatchDragEvent(@el, "dragenter")
      expect(@el.classList.contains("hover")).toBeTruthy()

    it "removes hoverClass on `dragleave`", ->
      dispatchDragEvent(@el, "dragenter")
      dispatchDragEvent(@el, "dragleave")
      expect(@el.classList.contains("hover")).toBeFalsy()

    it "removes `hoverClass` on `drop`", ->
      dispatchDragEvent(@el, "dragenter")
      dispatchDragEvent(@el, "drop")
      expect(@el.classList.contains("hover")).toBeFalsy()

  describe "#disable", ->
    set "options", -> {over: jasmine.createSpy("over")}
    it "disables it", ->
      @droppable.disable()
      {@event} = dispatchDragEvent(@el, "dragenter")
      expect(@options.over).not.toHaveBeenCalled()

  describe "#enable", ->
    set "options", -> {over: jasmine.createSpy("over")}
    it "enables it", ->
      @droppable.disable()
      @droppable.enable()
      {@event} = dispatchDragEvent(@el, "dragenter")
      expect(@options.over).toHaveBeenCalled()

  describe "@isBound", ->
    set "options", -> {drop: jasmine.createSpy("drop")}
    it "prevents multiple `dragenter` events from causing multiple events", ->
      dispatchDragEvent(@el, "dragenter")
      dispatchDragEvent(@el, "dragenter")
      dispatchDragEvent(@el, "drop")
      expect(@options.drop.calls.all().length).toEqual(1)
