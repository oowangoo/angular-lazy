(function() {
  var stateModule;

  stateModule = angular.module('angular.lazy.state', ['ng', 'ui.router', 'angular.lazy.require', 'angular.lazy.register']);

  stateModule.config([
    '$stateProvider', '$fileLoadProvider', function($stateProvider, $fileLoadProvider) {
      var registerState;
      registerState = $stateProvider.state;
      return $stateProvider.state = function(name, config) {
        var jsRequire, resolve;
        if (config.requirejs) {
          jsRequire = config.requirejs;
        } else {
          jsRequire = $fileLoadProvider.findRequire(name);
        }
        if (jsRequire && (resolve = config.resolve || {})) {
          angular.forEach(jsRequire, function(v, k) {
            resolve["loadJSFile" + k] = function() {
              return $fileLoadProvider.getFile(v, name);
            };
          });
          config.resolve = resolve;
        }
        return registerState.apply(this, arguments);
      };
    }
  ]);

}).call(this);
