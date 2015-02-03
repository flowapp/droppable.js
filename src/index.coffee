Sortable = require("./sortable")
Draggable = require("./draggable")
Droppable = require("./droppable")

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
