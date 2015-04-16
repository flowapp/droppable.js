dispatchDragEvent = require("./helpers/dispatch_drag_event")
Sortable = require("droppable").Sortable
_ = require("lodash")

describe "Sortable", ->
  set "options", -> {}

  beforeEach ->
    @el = document.createElement("div")
    @el.style.width = "400px"
    @el.style.position = "absolute"
    @el.style.top = "100px"
    @el.style.left = "100px"

    for index in [0..5]
      item = document.createElement("div")
      item.style.height = "40px"
      item.className = "sortable-item"
      item.textContent = index
      item.setAttribute("draggable", "true")
      @el.appendChild(item)

    document.body.appendChild(@el)
    @sortable = new Sortable(@el, _.defaults({}, @options, {
      items: ".sortable-item"
      insertPlaceholder: (@placeholder) =>
      placeholder: ->
        element = document.createElement("div")
        element.style.height = "40px"
        element
    }))

  afterEach ->
    document.body.removeChild(@el)

  describe "dragover", ->
    set "dragoverProperties", -> {clientX: 10, clientY: 130}
    set "dragContext", -> {}

    beforeEach ->
      @target = @el.querySelector("div")
      {data} = dispatchDragEvent(@target, "dragstart", undefined, @dragContext)
      dispatchDragEvent(@target, "dragover", @dragoverProperties, data)

    describe "`options.over`", ->
      set "options", -> {over: jasmine.createSpy("over")}
      it "calls `options.over`", ->
        expect(@options.over).toHaveBeenCalled()

    describe "flipping", ->
      describe "after target", ->
        set "options", -> {insertPlaceholder: jasmine.createSpy("insertPlaceholder")}
        it "calls `options.insertPlaceholder`", ->
          expect(@options.insertPlaceholder).toHaveBeenCalledWith(
            jasmine.any(Node),
            [@target],
            jasmine.any(Object)
          )

        it "inserts placeholder after target", ->
          placeholder = @options.insertPlaceholder.calls.argsFor(0)[0]
          expect(@target.nextElementSibling).toEqual(placeholder)

      describe "{first child}", ->
        set "dragoverProperties", -> {clientX: 10, clientY: 110}
        set "options", -> {insertPlaceholder: jasmine.createSpy("insertPlaceholder")}
        it "calls `options.insertPlaceholder`", ->
          expect(@options.insertPlaceholder).toHaveBeenCalledWith(
            jasmine.any(Node),
            [@target],
            jasmine.any(Object)
          )

        it "inserts placeholder before placeholder", ->
          placeholder = @options.insertPlaceholder.calls.argsFor(0)[0]
          expect(@target.previousElementSibling).toEqual(placeholder)

      describe "{last child}", ->
        set "dragoverProperties", -> {clientX: 10, clientY: 330 + 40}
        set "options", -> {insertPlaceholder: jasmine.createSpy("insertPlaceholder")}
        it "calls `options.insertPlaceholder`", ->
          expect(@options.insertPlaceholder).toHaveBeenCalledWith(
            jasmine.any(Node),
            [@target],
            jasmine.any(Object)
          )

        it "inserts placeholder as last child", ->
          placeholder = @options.insertPlaceholder.calls.argsFor(0)[0]
          expect(@target.nextElementSibling).toEqual(placeholder)

    describe "`options.accepts`", ->
      set "accepts", -> "name"
      set "options", ->
        {
          over: jasmine.createSpy("over")
          accepts: jasmine.createSpy("accepts").and.returnValue(@accepts)
        }

      it "calls `options.accepts`", ->
        expect(@options.accepts).toHaveBeenCalled()

      it "cancels", ->
        expect(@options.over).not.toHaveBeenCalled()

      describe "calls through if matches `accepts` return value", ->
        set "dragContext", -> {name: "Walter White"}
        it "works", ->
          expect(@options.over).toHaveBeenCalled()

      describe "returning truthy", ->
        set "accepts", -> true
        it "accepts truthy values", ->
          expect(@options.over).toHaveBeenCalled()

      describe "returning falsy", ->
        set "accepts", -> false
        it "rejects falsy values", ->
          expect(@options.over).not.toHaveBeenCalled()

  describe "removes placeholder on `dragleave`", ->
    set "options", -> {insertPlaceholder: jasmine.createSpy("insertPlaceholder")}

    beforeEach ->
      @target = @el.querySelector("div")
      {data} = dispatchDragEvent(@target, "dragstart")
      dispatchDragEvent(@target, "dragover", {clientX: 10, clientY: 130}, data)
      @placeholder = @options.insertPlaceholder.calls.argsFor(0)[0]
      dispatchDragEvent(@target, "dragleave", {clientX: 0, clientY: 0}, data)

    # Redundant spec, but a safe net that’s worth to have
    it "sets up environment correctly", ->
      expect(@options.insertPlaceholder).toHaveBeenCalled()

    it "removes `placeholder` from the DOM", ->
      expect(document.body.contains(@placeholder)).toBeFalsy()

  describe "`options.out`", ->
    set "options", -> {out: jasmine.createSpy("out")}

    beforeEach ->
      @target = @el.querySelector("div")
      {data} = dispatchDragEvent(@target, "dragstart")
      dispatchDragEvent(@target, "dragover", {clientX: 10, clientY: 130}, data)
      dispatchDragEvent(@target, "dragleave", {clientX: 0, clientY: 0}, data)

    it "calls `options.out`", ->
      expect(@options.out).toHaveBeenCalledWith(
        jasmine.any(Object),
        @el, # TODO figure out if this is correct, seems incorrect
        jasmine.any(Array)
      )

  describe "dragend", ->
    set "options", -> {stop: jasmine.createSpy("stop")}
    beforeEach ->
      @target = @el.querySelector("div")
      {data} = dispatchDragEvent(@target, "dragstart")
      dispatchDragEvent(@target, "dragover", {clientX: 10, clientY: 130}, data)
      dispatchDragEvent(@target, "dragend", {clientX: 0, clientY: 0}, data)

    it "calls `options.stop`", ->
      expect(@options.stop).toHaveBeenCalledWith([@target])

    it "removes placeholder", ->
      expect(document.body.contains(@placeholder)).toEqual(false)

  describe "drop", ->
    set "options", -> {sort: jasmine.createSpy("sort")}
    beforeEach ->
      @startTarget = @el.children[0]
      @endTarget = @el.children[2]
      {data} = dispatchDragEvent(@startTarget, "dragstart")
      dispatchDragEvent(@endTarget, "dragover", {clientX: 10, clientY: 300}, data)
      dispatchDragEvent(@endTarget, "drop", {clientX: 10, clientY: 300}, data)

    it "removes placeholder", ->
      expect(document.body.contains(@placeholder)).toEqual(false)

    describe "`options.sort`", ->
      it "calls `options.sort`", ->
        expect(@options.sort).toHaveBeenCalledWith(
          2
          jasmine.any(Object)
          [@startTarget]
        )

    describe "`options.stop`", ->
      set "options", -> {stop: jasmine.createSpy("stop")}
      it "calls `options.stop`", ->
        expect(@options.stop).toHaveBeenCalledWith([@startTarget])

    describe "rearranges the DOM", ->
      set "options", -> {manual: false}
      it "works", ->
        expect(@el.children[2]).toEqual(@startTarget)

    describe "`options.manual`", ->
      set "options", -> {manual: true}
      it "keeps dropped target at original index", ->
        expect(@el.children[0]).toEqual(@startTarget)

      set "options", -> {manual: true, sort: jasmine.createSpy("sort")}
      it "subtracts dropped targets from index calculation", ->
        expect(@options.sort).toHaveBeenCalledWith(
          2
          jasmine.any(Object)
          [@startTarget]
        )
