// HACK browserify doesn’t really support peer dependencies and we don’t want to
// embed jQuery becuase it’s probably already included.
window.$ = require("jquery")
