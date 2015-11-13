module = angular.module 'angular.lazy.require',['ng']

requireConfig = {}
module.setConfig = (config)->
  requireConfig = angular.extend(requireConfig,config) 
  return module

module.factory("$fileCache",["$cacheFactory",($cacheFactory)->
  return $cacheFactory("fileCache")
])
.provider("$fileLoad",[()->
  #return paths array 
  getRequireList = (config)->
    return [] unless config
    return config if angular.isArray(config)
    return [].push(config) if angular.isString(config)
    if angular.isObject(config)
      list = []
      angular.forEach(config,(v,k)->
        list.concat(getRequireList(v))
      )
    return list

  getFilePath = (fileName,relativePath)->
    baseRequire = module.findRequire()
    if relativePath 
      baseRequire = baseRequire[relativePath]
    return '' unless baseRequire
    return baseRequire[fileName]

  provider = @
  provider.onError = angular.noop
  provider.setConfig = module.setConfig

  provider.findRequire = (stateName)->
    requireList = requireConfig[stateName] || []
    requireList = getRequireList(requireList)
    return requireList

  provider.getFile = ()->
    ;

  provider.$get = ['$q','$fileCache',($q,$fileCache)->
    class ScriptLoad
      constructor:(filePath)->
        deferred = $q.defer()
        
        @onScriptLoad = ()->
          deferred.resolve();
          fileCache.put(filePath,'has cache')
          return

        @onScriptError = ()->
          deferred.reject(); 
          provide.onError()
          return

        if filePath || fileCache.get(filePath)
          deferred.resolve();
        else 
          @loadScript(filePath)

        @promise = deferred.promise 
        return @
      loadScript:(url)->
        onScriptError = @onScriptError.bind(@)
        onScriptLoad = @onScriptLoad.bind(@)
        node = createNode();

        node.addEventListener('load',onScriptLoad)
        node.addEventListener('error',onScriptError)

        node.src = url;
        head.appendChild(node);
      createNode:()->
        node = document.createElement("script")
        node.type = "text/javascript"
        node.charset = 'utf-8'
        node.async = true
        return node 

    provider.getFile = (filepath)->
      return new ScriptLoad(filepath).promise

  ]

  return provider
]).run(["$fileLoad",($fileLoad)->
  return
])

