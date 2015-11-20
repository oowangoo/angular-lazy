(function() {
  var ModuleListenList, anonFn, appendModuleRequires, coverNgModule, createInvoke, getQueueArguments, head, hitCache, initRegisterCache, isRegister, moduleProxy, nextTick, putRegisterCache, register, registerCache, requireConfig, requireModule, stateModule;

  register = angular.module('angular.lazy.register', ['ng']);

  register.isBootstrap = false;

  register.isRegister = isRegister = function(moduleName) {
    return !!registerCache.module[moduleName];
  };

  ModuleListenList = ['provider', 'factory', 'service', 'value', 'constant', 'animation', 'filter', 'controller', 'directive', 'config', 'run'];

  registerCache = {
    module: {
      'ng': true
    }
  };

  initRegisterCache = function() {
    var method, _i, _len, _results;
    registerCache = {
      module: {
        'ng': true
      }
    };
    _results = [];
    for (_i = 0, _len = ModuleListenList.length; _i < _len; _i++) {
      method = ModuleListenList[_i];
      _results.push(registerCache[method] = {});
    }
    return _results;
  };

  initRegisterCache();

  getQueueArguments = function(args) {
    var fn, name;
    name = args[0];
    fn = args[1];
    if (!fn) {
      fn = name;
      name = '@';
    }
    if (angular.isArray(fn)) {
      fn = fn[fn.length - 1];
    }
    return {
      name: name,
      fn: fn
    };
  };

  anonFn = function(fn) {
    return fn.toString();
  };

  hitCache = function(method, args) {
    var cache, caches, fn, name;
    caches = registerCache[method];
    args = getQueueArguments(args);
    name = args.name;
    fn = args.fn;
    cache = caches[name];
    if (!cache) {
      return false;
    }
    if (!angular.isArray(cache)) {
      return true;
    }
    return cache.indexOf(anonFn(fn)) > -1;
  };

  putRegisterCache = function(method, args) {
    var caches, fn, name;
    caches = registerCache[method];
    args = getQueueArguments(args);
    name = args.name;
    fn = args.fn;
    if (['run', 'config', 'directive'].indexOf(method) > -1) {
      caches[name] = caches[name] || [];
      caches[name].push(anonFn(fn));
    } else {
      caches[name] = true;
    }
  };

  moduleProxy = function(module) {
    var method, _i, _len;
    registerCache.module[module.name] = true;
    for (_i = 0, _len = ModuleListenList.length; _i < _len; _i++) {
      method = ModuleListenList[_i];
      module[method] = createInvoke(module, method);
    }
    module.$isProxy = true;
    return module;
  };

  createInvoke = function(module, method) {
    var invokeQueue, normal;
    normal = module[method];
    if (!normal || !angular.isFunction(normal)) {
      throw new Error("badmethod  no method " + method + " name");
    }
    invokeQueue = function() {
      var result;
      if (hitCache(method, arguments)) {
        return module;
      }
      result = normal.apply(module, arguments);
      putRegisterCache(method, arguments);
      if (register.isBootstrap) {
        register.register(module, method, arguments);
      }
      return result;
    };
    return invokeQueue;
  };

  appendModuleRequires = function(moduleName, requires) {
    var appendList, baseRequires, module, req, _i, _len;
    module = angular.module(moduleName);
    baseRequires = module.requires;
    appendList = [];
    for (_i = 0, _len = requires.length; _i < _len; _i++) {
      req = requires[_i];
      if (baseRequires.indexOf(req) === -1) {
        appendList.push(req);
      }
    }
    Array.prototype.push.apply(baseRequires, appendList);
    return module;
  };

  coverNgModule = function() {
    var normalModule;
    normalModule = angular.module;
    return angular.module = function(name, requires, fn) {
      var module;
      if (requires && isRegister(name)) {
        return appendModuleRequires(name, requires);
      }
      module = normalModule(name, requires, fn);
      if (module.$isProxy) {
        return module;
      }
      return moduleProxy(module);
    };
  };

  nextTick = function(fn, delay) {
    return setTimeout(fn, delay || 0);
  };

  register.directive("body", [
    function() {
      return {
        restrict: "E",
        compile: function() {
          return register.isBootstrap = true;
        }
      };
    }
  ]).provider("register", [
    "$provide", "$controllerProvider", "$compileProvider", "$filterProvider", "$injector", "$animateProvider", function($provide, $controllerProvider, $compileProvider, $filterProvider, $injector, $animateProvider) {
      var invokeLater, providerCache, providers, registerFunction, runLater, self;
      self = this;
      providerCache = {};
      providers = {
        $provide: $provide,
        $controllerProvider: $controllerProvider,
        $compileProvider: $compileProvider,
        $filterProvider: $filterProvider,
        $injector: $injector,
        $animateProvider: $animateProvider,
        getInstanceInjector: function() {
          return angular.injector();
        }
      };
      invokeLater = function(pname, method) {
        var provider;
        provider = providers[pname];
        if (!provider) {
          throw new Error("badProvider unsupported provider " + pname);
        }
        return function() {
          var rs;
          rs = provider[method].apply(provider, arguments);
        };
      };
      runLater = function() {
        return function(block) {
          var instance;
          instance = providers.getInstanceInjector();
          return nextTick(function() {
            return instance.invoke(block);
          });
        };
      };
      registerFunction = {
        provider: invokeLater('$provide', 'provider'),
        factory: invokeLater('$provide', 'factory'),
        service: invokeLater('$provide', 'service'),
        value: invokeLater('$provide', 'value'),
        constant: invokeLater('$provide', 'constant', 'unshift'),
        animation: invokeLater('$animateProvider', 'register'),
        filter: invokeLater('$filterProvider', 'register'),
        controller: invokeLater('$controllerProvider', 'register'),
        directive: invokeLater('$compileProvider', 'directive'),
        config: invokeLater('$injector', 'invoke', 'push', "_configBlocks"),
        run: runLater()
      };
      register.register = function(module, method, args) {
        var rFn;
        rFn = registerFunction[method];
        if (!rFn) {
          throw new Error("badFunctioin unsupproted register " + method);
        }
        rFn.apply(this, args);
      };
      this.$get = [
        '$rootElement', function($rootElement) {
          var instanceInjector;
          instanceInjector = null;
          providers.getInstanceInjector = function() {
            if (!instanceInjector) {
              instanceInjector = $rootElement.data('$injector') || angular.injector();
            }
            return instanceInjector;
          };
          return register.register;
        }
      ];
      return this;
    }
  ]).run(['register', function(service) {}]);

  coverNgModule();

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
    function() {
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
          list = [];
          angular.forEach(config, function(v, k) {
            return Array.prototype.push.apply(list, getRequireList(v));
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
              this.onScriptError = function() {
                deferred.reject('bad request');
                fileCache.remove(filePath);
                $rootScope.$apply();
                angular.isFunction(provider.onError) && provider.onError();
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
            var load;
            load = new ScriptLoad(filepath);
            if (load.$promise) {
              return load.$promise;
            } else {
              return load;
            }
          };
        }
      ];
      return provider;
    }
  ]).run(["$fileLoad", function($fileLoad) {}]);

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
