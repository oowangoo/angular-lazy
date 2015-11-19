// Karma configuration
// Generated on Wed Mar 18 2015 17:29:04 GMT+0800 (CST)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],


    // list of files / patterns to load in the browser
    files: [
      "vendor/angular/angular.js",
      "vendor/angular-mocks/angular-mocks.js",
      "vendor/angular-ui-router/release/angular-ui-router.js",
      ".compiled/angular-lazy.min.js",
      ".compiled/test/unit/*.js",
      ".compiled/test/module.js",
      ".compiled/test/empty.js"
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome','Safari','Firefox'],
    plugins : [
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      "karma-safari-launcher",
      'karma-jasmine',
      // 'karma-coverage',
      'karma-junit-reporter'
    ],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true
  });
};
