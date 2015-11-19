(function() {
  var ModuleListenList, appendModuleRequires, coverNgModule, createInvoke, isRegister, moduleProxy, nextTick, register, registerCache;

  register = angular.module('angular.lazy.register', ['ng']);

  register.isBootstrap = false;

  registerCache = {
    modules: ['ng']
  };

  register.isRegister = isRegister = function(moduleName) {
    return registerCache.modules.indexOf(moduleName) !== -1;
  };

  ModuleListenList = ['provider', 'factory', 'service', 'value', 'constant', 'animation', 'filter', 'controller', 'directive', 'config', 'run'];

  moduleProxy = function(module) {
    var method, _i, _len;
    registerCache.modules.push(module.name);
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
      result = normal.apply(module, arguments);
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
          var cacheName, name, rs;
          name = arguments[0];
          cacheName = "" + method + name;
          if (self.enableDistinst && providerCache[cacheName]) {
            return;
          }
          rs = provider[method].apply(provider, arguments);
          providerCache[cacheName] = rs;
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

}).call(this);
