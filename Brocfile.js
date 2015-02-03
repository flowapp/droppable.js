var coffeeScriptCompiler = require("broccoli-coffee");
var browserify = require("broccoli-browserify");

var coffeeTree = coffeeScriptCompiler("src");

module.exports = browserify(coffeeTree, {
  entries: ["./index"],
  outputFile: "droppable.js"
});
