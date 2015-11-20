describe("require",()->
  beforeEach(module("angular.lazy.require"))
  # xit("promise",inject(($q,$rootScope)->
  #   deferred = $q.defer();
  #   promise = deferred.promise;
  #   resolvedValue = undefined
  #   promise.then((value)->
  #    resolvedValue = value
  #   );
  #   expect(resolvedValue).toBeUndefined();
  #   deferred.resolve(123);
  #   expect(resolvedValue).toBeUndefined(); # not in then function 
  #   $rootScope.$apply();
  #   expect(resolvedValue).toEqual(123); # in then function 
  # ))
  beforeEach(()->
    window.lazyLoad = true
  )
  it("getFile",(done)->
    inject(($fileLoad,$rootScope)->
      path = "/base/.compiled/test/module.js"
      p = $fileLoad(path)
      expect(p.then).toBeDefined()
      p.then(()->
        expect(!window.lazyLoad).toBeTruthy()
      ).catch(()->
        console.error(["can't load #{path}"])
        expect(false).toBeTruthy()
      ).finally(()->
        done()
      )
      $rootScope.$digest();
      
      # twice 
      p = $fileLoad(path)
      expect(p.then).toBeDefined()
      p.then(()->
        expect(!window.lazyLoad).toBeTruthy()
      ).catch(()->
        console.error(["can't load #{path}"])
        expect(false).toBeTruthy()
      ).finally(()->
        done()
      )
      $rootScope.$digest();
    )
  )
  it("getFile Array",(done)->
    inject(($fileLoad,$rootScope,$fileCache)->
      $fileCache.remove("/base/.compiled/test/module.js")
      $fileCache.remove("/base/.compiled/test/empty.js")
      
      window.lazyLoad = true
      window.stateResovle = true
      
      p = $fileLoad(["/base/.compiled/test/module.js","/base/.compiled/test/empty.js"])
      expect(p.then).toBeDefined()
      p.then(()->
        expect(!window.lazyLoad).toBeTruthy()
        expect(!window.stateResovle).toBeTruthy()
      ).catch(()->
        console.error(["can't load #{path}"])
        expect(false).toBeTruthy()
      ).finally(()->
        done()
      )
      $rootScope.$digest();

      $fileCache.remove("/base/.compiled/test/module.js")
      $fileCache.remove("/base/.compiled/test/empty.js")
    )
  )
  describe('provider',()->
    fileProvider = undefined;
    A =  {
      'project':'somefilepath'
      'other': [ 'somefilepath']
    }
    B = {
      'project':['somefilepath','somefilepath2']
    }
    C = {
      'project':
        'highchart':
          'highchart'    : "highchart-path"
          'highchart-ng' : "highchart-ng-path"
    }

    beforeEach(module(($fileLoadProvider)->
      fileProvider = $fileLoadProvider
      expect(fileProvider).toBeDefined()
      fileProvider.setConfig({})
      return
    ))
    it("string",inject(()->
      fileProvider.setConfig(A)
      array = fileProvider.findRequire("project")
      expect(array.length).toBe(1)
      expect(array[0]).toBe("somefilepath")
      return
    ))
    it("array",inject(()->
      fileProvider.setConfig(B)
      array = fileProvider.findRequire("project")
      expect(array.length).toBe(2)
      expect(array).toContain("somefilepath")
      expect(array).toContain("somefilepath2")
      return
    ))
    it("object",inject(()->
      fileProvider.setConfig(C)
      array = fileProvider.findRequire("project")
      expect(array.highchart).toBeDefined()
      expect(array.highchart.highchart).toBe("highchart-path")
      expect(array.highchart["highchart-ng"]).toBe("highchart-ng-path")
      # expect(array.length).toBe(2)
      # expect(array).toContain("highchart-path")
      # expect(array).toContain("highchart-ng-path")
      return
    ))
    return
  )
)