Sortable = require("./sortable")
Draggable = require("./draggable")
Droppable = require("./droppable")

factory = ($) ->
  $.fn.droppable = (options = {}) ->
    values = for element in this
      (new Droppable(element, options))

    values

  $.fn.draggable = (options = {}) ->
    values = for element in this
      (new Draggable(element, options))

    values

  $.fn.sortable = (options = {}) ->
    values = for element in this
      (new Sortable(element, options))

    values

if typeof define == "function" && define.amd
  define(["jquery"], factory)
else
  factory(jQuery)
