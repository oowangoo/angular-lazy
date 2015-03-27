#
# 参照https://github.com/ocombe/ocLazyLoad/blob/master/src/ocLazyLoad.js 实现lazy加载
#
lazyModule = angular.module 'angular.lazy', ['ng']

#property
server = window 
server.isBootstrap = false
#记录原有module定义方法，重写模块定义方法，记录已经定义过的模块
_moduleFn = angular.module 
angular.module = (name,require,fn)->
  rs = _moduleFn(name,require,fn)
  #获取module
  if !require
    return rs
  #封装其对外暴露的方法
  appendModuleFn(rs)

  return rs
# 重写module的controller,provider,directive,filter方法
appendModuleFn = (module)->
  #保存原有方法
  normal = {
    controller:module.controller
    directive:module.directive
    provider:module.provider
    filter:module.filter
    run:module.run
  }
  ###*
  fn为module原有方法(_controllerFn,_directiveFn,_providerFn,_filterFn,_runBlocks)
  ###
  invokeQueue = (fname,args)->
    fn = normal[fname]
    if !fn #如果没有，则说明不支持异步注册，调用module看看有没有
      n = module[fname]
      if n 
        return n.apply(n,args)
      else #如果module没有则说明ng本身并没有此方法
        throw new Error("badmethod no method #{fname} name")
    #ng未初始化(不管是否初始化，都先调用ng原有方法)
    r = fn.apply(fn,args)
    if server.isBootstrap #ng已初始化,注册相应对象(注册module时可先检查是否依赖项已经注册，如果依赖项没注册则等待所有依赖项注册完成后在注册)
      server.register(module,fname,args);#注册
    return r
  
  #重写module方法,以保证后续使用的方法能够正常注册
  module.controller = ()->
    return invokeQueue("controller",arguments)
  module.drective = ()->
    return invokeQueue("directive",arguments)  
  module.provider = ()->
    return invokeQueue("provider",arguments)  
  module.filter = ()->
    return invokeQueue("filter",arguments)
  module.run = ()->
    return invokeQueue("run",arguments) #也许这个应该是执行，而不是注册

#添加指令，用来判断ng已经加载完成,如果有更好地方式再改,并且依赖register保证ng调用registerPrivder的$get方法
lazyModule.directive('body',['register',(register)->
  # restrict:'E'
  compile: ()->
    server.isBootstrap = true
])

#注入各种provider以便注册使用
lazyModule.provider('register',($provide,$controllerProvider,$compileProvider,$filterProvider,$injector,$animateProvider)->
  providers = {
    $provide
    $controllerProvider
    $compileProvider
    $filterProvider
    $injector
    $animateProvider
    getInstanceInjector:()->
      return angular.injector()
  }
  instanceInjector = null
  mainRegister = (module,fname,args)->
    rFn = registerFn[fname]
    if !rFn
      throw new Error("badFunction unsupproted register #{fname}")
    #注册
    rFn.apply(rFn,args) 

  server.register = mainRegister

  #返回注册方法
  invokeLater = (pname, method, insertMethod, queue)->
    provider = providers[pname]
    unless provider
      throw new Error("badProvider unsupported provider #{pname}")
    return ()->
      #执行注册操作
      provider[method].apply(provider,arguments);
  runLater = ()->
    return ()->
      instance = providers.getInstanceInjector()
      instance.invoke(arguments)
  registerFn ={ #缺少module
    provider:invokeLater('$provide', 'provider')
    factory: invokeLater('$provide', 'factory')
    service: invokeLater('$provide', 'service')
    value: invokeLater('$provide', 'value')
    constant: invokeLater('$provide', 'constant', 'unshift')
    animation: invokeLater('$animateProvider', 'register')
    filter: invokeLater('$filterProvider', 'register')
    controller: invokeLater('$controllerProvider', 'register')
    directive: invokeLater('$compileProvider', 'directive')
    config: invokeLater('$injector', 'invoke', 'push', "_configBlocks")
    run:runLater()
  }
  
  
  @$get = ['$rootElement',($rootElement)->
    providers.getInstanceInjector = ()->
      return if instanceInjector
      instanceInjector = $rootElement.data('$injector') || angular.injector()
    return server.register
  ]
  return @;
)
