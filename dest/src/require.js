(function() {
  var head, requireConfig, requireModule;

  requireModule = angular.module('angular.lazy.require', ['ng']);

  head = document.getElementsByTagName("head")[0];

  requireConfig = {};

  requireModule.setConfig = function(config) {
    if (!config) {
      requireConfig = {};
    } else {
      requireConfig = angular.extend(requireConfig, config);
    }
    return requireModule;
  };

  requireModule.factory("$fileCache", [
    "$cacheFactory", function($cacheFactory) {
      return $cacheFactory("fileCache");
    }
  ]).provider("$fileLoad", [
    '$injector', function($injector) {
      var getFilePath, getRequireList, provider;
      getRequireList = function(config) {
        var list;
        if (angular.isArray(config)) {
          return config;
        }
        list = [];
        if (!config) {

        } else if (angular.isString(config)) {
          list.push(config);
        } else if (angular.isObject(config)) {
          list = {};
          angular.forEach(config, function(v, k) {
            return list[k] = v;
          });
        }
        return list;
      };
      getFilePath = function(fileName, relativePath) {
        var baseRequire;
        baseRequire = requireModule.findRequire();
        if (relativePath) {
          baseRequire = baseRequire[relativePath];
        }
        if (!baseRequire) {
          return '';
        }
        return baseRequire[fileName];
      };
      provider = this;
      provider.onError = angular.noop;
      provider.setConfig = requireModule.setConfig;
      provider.findRequire = function(stateName) {
        var requireList;
        requireList = requireConfig[stateName] || [];
        requireList = getRequireList(requireList);
        return requireList;
      };
      provider.getFile = function() {};
      provider.$get = [
        '$q', '$fileCache', '$rootScope', function($q, fileCache, $rootScope) {
          var ScriptLoad;
          ScriptLoad = (function() {
            function ScriptLoad(filePath) {
              var deferred, that;
              if (filePath && (that = fileCache.get(filePath))) {
                return that;
              }
              deferred = $q.defer();
              this.$promise = deferred.promise;
              this.onScriptLoad = function() {
                deferred.resolve(123);
                fileCache.put(filePath, true);
                $rootScope.$apply();
              };
              this.onScriptError = function(event) {
                event = event || {};
                event.filepath = filePath;
                deferred.reject('bad request');
                fileCache.remove(filePath);
                $rootScope.$apply();
                $rootScope.$emit("$scriptLoadError", event);
              };
              if (!filePath) {
                deferred.reject('empty path');
              } else {
                fileCache.put(filePath, this);
                this.loadScript(filePath);
              }
              return this;
            }

            ScriptLoad.prototype.loadScript = function(url) {
              var node, onScriptError, onScriptLoad;
              onScriptError = this.onScriptError.bind(this);
              onScriptLoad = this.onScriptLoad.bind(this);
              node = this.createNode();
              node.addEventListener('load', onScriptLoad);
              node.addEventListener('error', onScriptError);
              node.src = url;
              return head.appendChild(node);
            };

            ScriptLoad.prototype.createNode = function() {
              var node;
              node = document.createElement("script");
              node.type = "text/javascript";
              node.charset = 'utf-8';
              node.async = true;
              node.setAttribute && node.setAttribute("ng-lazy", "load");
              return node;
            };

            return ScriptLoad;

          })();
          return provider.getFile = function(filepath) {
            var load, promise;
            if (angular.isArray(filepath)) {
              promise = [];
              angular.forEach(filepath, function(file) {
                var load;
                load = new ScriptLoad(file);
                if (load && load.$promise) {
                  return promise.push(load.$promise);
                }
              });
              return $q.all(promise);
            } else {
              load = new ScriptLoad(filepath);
              if (load.$promise) {
                return load.$promise;
              } else {
                return load;
              }
            }
          };
        }
      ];
      return provider;
    }
  ]).run(["$fileLoad", function($fileLoad) {}]);

}).call(this);
