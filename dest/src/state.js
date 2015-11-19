(function() {
  var stateModule;

  stateModule = angular.module('angular.lazy.state', ['ng', 'ui.router', 'angular.lazy.require', 'angular.lazy.register']);

  stateModule.config([
    '$stateProvider', '$fileLoadProvider', function($stateProvider, $fileLoadProvider) {
      var registerState;
      registerState = $stateProvider.state;
      return $stateProvider.state = function(name, config) {
        var jsRequire, loadFile, resolve;
        if (config.requirejs) {
          jsRequire = config.requirejs;
        } else {
          jsRequire = $fileLoadProvider.findRequire(name);
        }
        if (jsRequire && (resolve = config.resolve || {})) {
          loadFile = [];
          angular.forEach(jsRequire, function(v, k) {
            var resolveName;
            resolveName = "loadJSFile" + k;
            resolve[resolveName] = function() {
              return $fileLoadProvider.getFile(v, name);
            };
            loadFile.push(resolveName);
          });
          loadFile.push(angular.noop);
          resolve.loadFile = loadFile;
          config.resolve = resolve;
        }
        return registerState.apply(this, arguments);
      };
    }
  ]);

}).call(this);
