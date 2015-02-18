var coffeeScriptCompiler = require("broccoli-coffee");
var browserify = require("broccoli-browserify");
var stew = require("broccoli-stew");
var ES6Compiler = require("broccoli-6to5-transpiler");
var merge = require("broccoli-merge-trees");

var sourceCoffeeTree = coffeeScriptCompiler("src");

var droppable = browserify(sourceCoffeeTree, {
  entries: ["./index"],
  outputFile: "droppable.js",
  bundle: {
    standalone: "droppable.js"
  }
});

// Tests

var testsTree = coffeeScriptCompiler("tests");
testsTree = ES6Compiler(testsTree, {
  modules: "common"
});

var tests = browserify(merge([
  stew.mv(droppable, "dist"),
  testsTree
]), {
  entries: ["./index"],
  require: [
    ["./dist/droppable", {expose: "droppable"}],
  ],
  outputFile: "tests.js"
});

module.exports = merge([droppable, tests]);
