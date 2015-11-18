router = angular.module("test.state",['angular.lazy.state','angular.lazy.register','ui.router'])
describe("state",()->

  stateProvider = null
  fileLoad = null

  beforeEach(module("test.state"))
  beforeEach(module(($stateProvider,$fileLoadProvider)->
    stateProvider = $stateProvider
    fileLoad = $fileLoadProvider
    return
  ))
  it("module set config",inject(($state)->
    rmod = angular.module 'angular.lazy.require'
    rmod.setConfig({
      project:"somefilepath"
    })
    stateProvider.state("project",{
      url:"/project"
    })
    p = $state.get("project")
    expect(p).toBeDefined()
    expect(p.resolve).toBeDefined()
    expect(angular.isFunction(p.resolve.loadJSFile0)).toBeTruthy()
  ))
  it("resolve by config",inject(($state)->
    fileLoad.setConfig({
      project:"somefilepath"
    })
    stateProvider.state("project",{
      url:"/project"
    })
    p = $state.get("project")
    expect(p).toBeDefined()
    expect(p.resolve).toBeDefined()
    expect(angular.isFunction(p.resolve.loadJSFile0)).toBeTruthy()
    return
  ))
  it("resolve by router requirejs ",inject(($state)->
    stateProvider.state("demo",{
      url:"/project"
      requirejs:{
        file:"filepath1"
      }
    })
    d = $state.get("demo")

    expect(d).toBeDefined()
    expect(d.resolve).toBeDefined()
    expect(angular.isFunction(d.resolve.loadJSFilefile)).toBeTruthy()

  ))
  return
)