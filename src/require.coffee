requireModule = angular.module 'angular.lazy.require',['ng']
head = document.getElementsByTagName("head")[0]
requireConfig = {}
requireModule.setConfig = (config)->
  unless config 
    requireConfig = {}
  else 
    requireConfig = angular.extend(requireConfig,config) 
  return requireModule

requireModule.factory("$fileCache",["$cacheFactory",($cacheFactory)->
  return $cacheFactory("fileCache")
])
.provider("$fileLoad",[()->
  #return paths array 
  getRequireList = (config)->
    return config if angular.isArray(config)
    list = []
    if !config
      ;
    else if angular.isString(config)
      list.push(config)
    else if angular.isObject(config)
      list = []
      angular.forEach(config,(v,k)->
        Array.prototype.push.apply(list,getRequireList(v))
      )
    return list

  getFilePath = (fileName,relativePath)->
    baseRequire = requireModule.findRequire()
    if relativePath 
      baseRequire = baseRequire[relativePath]
    return '' unless baseRequire
    return baseRequire[fileName]

  provider = @
  provider.onError = angular.noop
  provider.setConfig = requireModule.setConfig

  provider.findRequire = (stateName)->
    requireList = requireConfig[stateName] || []
    requireList = getRequireList(requireList)
    return requireList

  #defined in $get 
  provider.getFile = ()->
    ;

  provider.$get = ['$q','$fileCache','$rootScope',($q,fileCache,$rootScope)->
    class ScriptLoad
      constructor:(filePath)->
        if filePath and (that = fileCache.get(filePath))
          return that

        deferred = $q.defer()
        @$promise = deferred.promise

        @onScriptLoad = ()->
          deferred.resolve(123);
          fileCache.put(filePath,true)
          $rootScope.$apply() #需要调用$apply 才能将结果传播
          return

        @onScriptError = ()->
          deferred.reject('bad request'); 
          fileCache.remove(filePath)
          $rootScope.$apply() 
          angular.isFunction(provider.onError) and provider.onError()
          return
        if !filePath
          deferred.reject('empty path')
        else 
          fileCache.put(filePath,@)
          @loadScript(filePath)

        return @
      loadScript:(url)->
        onScriptError = @onScriptError.bind(@)
        onScriptLoad = @onScriptLoad.bind(@)
        node = @createNode();

        node.addEventListener('load',onScriptLoad)
        node.addEventListener('error',onScriptError)

        node.src = url;
        head.appendChild(node);
      createNode:()->
        node = document.createElement("script")
        node.type = "text/javascript"
        node.charset = 'utf-8'
        node.async = true
        node.setAttribute and node.setAttribute("ng-lazy","load")
        return node 

    return provider.getFile = (filepath)->
      load = new ScriptLoad(filepath)
      if load.$promise then load.$promise else load

  ]

  return provider
]).run(["$fileLoad",($fileLoad)->
  return
])

