register = angular.module 'angular.lazy.register',['ng']
#是否已经初始化
register.isBootstrap = false;
# 已经注册列表
registerCache = {
  modules   : ['ng']
  providers : []
}
register.isRegister = isRegister = (moduleName)->
  return registerCache.modules.indexOf(moduleName) isnt -1 

ModuleListenList = ['controller','directive','provider','filter','run']

#入口返回替换过的module对象    
moduleProxy = (module)->
  registerCache.modules.push module.name
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
#添加module 的requires对象
appendModuleRequires = (moduleName,requires)->
  module = angular.module(moduleName)
  begin = module.requires.length || 0
  end = requires.length - 1
  
  while(begin < end )
    req = requires[begin]
    module.requires.push req
    begin++
  return module

coverNgModule = ()->
  normalModule = angular.module
  angular.module = (name,requires,fn)->
    #todo 如果是注册，则需要判断是否注册过，如果没，调用ng，如果注册过，则将不同的依赖添加进原来对象
    if requires and isRegister(name)
      return appendModuleRequires(name,requires)
    module = normalModule(name,requires,fn)
    if module.$isProxy 
      return module
    #注册module，返回代理对象
    return moduleProxy(module)
#重写angular pbulic method
coverNgModule()

#依赖只是单纯为了让server初始化
register.directive("body",[()->
  return 
    compile: ()->
      register.isBootstrap = true
])
.provider("register",($provide,$controllerProvider,$compileProvider,$filterProvider,$injector,$animateProvider)->
  #所有已经注册过的对象,#{name}Provider = provider

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
  # public for register 

  
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


