module.exports = function(config) {
  config.set({
    basePath: "",
    frameworks: ["jasmine"],
    files: [
      {pattern: "src/**/*", watched: true, included: false, served: false},
      {pattern: "tests/**/*", watched: true, included: false, served: false},
      "http://localhost:4200/droppable.js",
      "http://localhost:4200/tests.js"
    ],
    exclude: [],
    reporters: ["progress"],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ["Chrome"],
    singleRun: false
  });
};
