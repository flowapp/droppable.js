Sortable = require("./sortable")
Draggable = require("./draggable")
Droppable = require("./droppable")

exports = {
  Sortable: Sortable
  Draggable: Draggable
  Droppable: Droppable
}

if typeof define == "function" && define.amd
  define(exports)
else
  window.Sortable = Sortable
  window.Draggable = Draggable
  window.Droppable = Droppable
