register = angular.module 'angular.lazy.register',['ng']
#是否已经初始化
register.isBootstrap = false;

ModuleListenList = ['controller','directive','provider','filter','run']

#入口返回替换过的module对象    
moduleProxy = (module)->
  for method in ModuleListenList
    module[method] = createInvoke(module,method)
  module.$isProxy = true
  return module
#替换module正常方法
createInvoke = (module,method)->
  normal = module[method]
  if !normal or !angular.isFunction(normal)
    throw new Error("badmethod  no method #{method} name")

  invokeQueue = ()->
    result = normal.apply(module,arguments)
    #已经初始化，则需要帮他注册
    if register.isBootstrap
      register.register(module,method,arguments)
    return result

  return invokeQueue


coverNgModule = ()->
  normalModule = angular.module
  angular.module = (name,requires,fn)->
    module = normalModule(name,requires,fn)
    unless requires 
      return module
    #注册module，返回代理对象
    return moduleProxy(module)

#依赖只是单纯为了让server初始化
register.directive("body",[()->
  return 
    compile: ()->
      register.isBootstrap = true
])
.provider("register",($provide,$controllerProvider,$compileProvider,$filterProvider,$injector,$animateProvider)->
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

  invokeLater = (pname,method)->
    provider = providers[pname]
    unless provider
      throw new Error("badProvider unsupported provider #{pname}"
    return ()->
      #执行注册操作
      provider[method].apply(provider,arguments);
  
  runLater = ()->
    return ()->
      instance = providers.getInstanceInjector()
      instance.invoke(arguments)

  registerFunction = {
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

  register.regiter = (module,method,args)->
    rFn = registerFunction[method]
    if !rFn 
      throw new Error("badFunctioin unsupproted register #{method}")
    rFn.apply(this,args)
    return
  @$get = ['$rootElement',($rootElement)->
    providers.getInstanceInjector = ()->
      return if instanceInjector
      instanceInjector = $rootElement.data('$injector') || angular.injector()
    return register.register
  ]
  return @
)
.run(['register',(register)->
  #初始化register
])


