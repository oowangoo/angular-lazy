stateModule = angular.module 'angular.lazy.state',['ng','ui.router','angular.lazy.require','angular.lazy.register']
# decorator $stateProvider.state
stateModule.config(['$stateProvider','$fileLoadProvider',($stateProvider,$fileLoadProvider)->
  registerState = $stateProvider.state
  #overflow register
  $stateProvider.state = (name,config)->
    
    if config.requirejs 
      jsRequire = config.requirejs
    else 
      jsRequire = $fileLoadProvider.findRequire(name)

    if jsRequire and (resolve = config.resolve || {})
      loadFile = []
      angular.forEach(jsRequire,(v,k)->
        resolveName = "loadJSFile#{k}"
        resolve[resolveName] = ()->
          return $fileLoadProvider.getFile(v,name)
        loadFile.push(resolveName)
        return
      )
      loadFile.push(angular.noop)
      resolve.loadFile = loadFile
      config.resolve = resolve
    return registerState.apply(this,arguments)
])
