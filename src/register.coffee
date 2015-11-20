register = angular.module 'angular.lazy.register',['ng']
#是否已经初始化
register.isBootstrap = false;
# 已经注册列表
register.isRegister = isRegister = (moduleName)->
  return !!registerCache.module[moduleName]

ModuleListenList = ['provider','factory','service','value','constant','animation','filter','controller','directive','config','run']

registerCache = {
  module   : {'ng':true}
}
initRegisterCache = ()->
  registerCache = {
    module   : {'ng':true}
  }
  for method in ModuleListenList
    registerCache[method] = {}

initRegisterCache()

#注册缓存
getQueueArguments = (args)->
  name = args[0]
  fn = args[1] 

  #只有1个参数时，一定是function
  if !angular.isDefined(fn)
    fn = name 
    name = '@'

  if angular.isArray(fn)
    fn = fn[fn.length - 1]
  return {
    name
    fn
  }

# FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m;
# STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;

anonFn = (fn)->
  # fnText = fn.toString().replace(STRIP_COMMENTS, '')
  # args = fnText.match(FN_ARGS)
  # if (args)
  #   return args[1] + fnText.length
  # else 
  #   return fnText
  return fn.toString()

hitCache = (method , args)->
  caches = registerCache[method]
  args = getQueueArguments(args)
  name = args.name
  fn = args.fn

  cache = caches[name]
  return false unless cache
  if !angular.isArray(cache)
    return true
  #cache is array
  return cache.indexOf(anonFn(fn)) > -1 

putRegisterCache = (method ,args)->
  caches = registerCache[method]
  args = getQueueArguments(args) 
  name = args.name
  fn = args.fn
  if ['run','config','directive'].indexOf(method) > -1
    caches[name] = caches[name] || []
    caches[name].push(anonFn(fn))
  else 
    caches[name] = true
  return

#入口返回替换过的module对象    
moduleProxy = (module)->
  registerCache.module[module.name] = true
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
    #判断重复
    # ng本身如果重名则会以后来的为准  判断是否已经注册过   如果改服务已经被使用由于ng的cache你获取到的永远是第一个，directive除外
    if hitCache(method,arguments)
      return module

    result = normal.apply(module,arguments)

    putRegisterCache(method,arguments)

    #已经初始化，则需要帮他注册
    if register.isBootstrap
      register.register(module,method,arguments)

    return result

  return invokeQueue
#添加module 的requires对象
appendModuleRequires = (moduleName,requires)->
  module = angular.module(moduleName)
  baseRequires = module.requires
  appendList = []
  for req in requires
    if baseRequires.indexOf(req) is -1
      appendList.push req
  Array.prototype.push.apply(baseRequires,appendList)
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

nextTick = (fn,delay)->
  setTimeout(fn,delay || 0)
#依赖只是单纯为了让server初始化
register.directive("body",[()->
  return {
    restrict: "E"
    compile: ()->
      register.isBootstrap = true
  }
])
.provider("register",[
  "$provide",
  "$controllerProvider",
  "$compileProvider",
  "$filterProvider",
  "$injector",
  "$animateProvider",
  ($provide,$controllerProvider,$compileProvider,$filterProvider,$injector,$animateProvider)->
    self = @
    #所有已经注册过的对象,#{name}Provider = provider
    providerCache = {

    }
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
        throw new Error("badProvider unsupported provider #{pname}")
      return ()->
        
        #执行注册操作
        rs = provider[method].apply(provider,arguments);


        return
    runLater = ()->
      return (block)->
        instance = providers.getInstanceInjector()
        # args = Array.prototype.slice.call(arguments,0);
        nextTick(()->
          instance.invoke(block)
        )

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

    
    register.register = (module,method,args)->
      rFn = registerFunction[method]
      if !rFn 
        throw new Error("badFunctioin unsupproted register #{method}")
      rFn.apply(this,args)
      return
    @$get = ['$rootElement',($rootElement)->
      instanceInjector = null
      providers.getInstanceInjector = ()->
        # 直接angular.injector()拿刀的injector是没有任何service，正常情况下是从rootElement中拿到injector
        unless instanceInjector
          instanceInjector = $rootElement.data('$injector') || angular.injector()
        return instanceInjector
      return register.register
    ]
    return @
])
.run(['register',(service)->
  #初始化register
])

coverNgModule()

