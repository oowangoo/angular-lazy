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
  
  it("getFile",(done)->
    inject(($fileLoad,$rootScope)->
      p = $fileLoad("http://localhost:3000/test/module.js")
      expect(p.then).toBeDefined()
      p.then(()->
        console.log("xxxx")
        expect(window.lazyLoad).toBeTruthy()
      ).catch(()->
        console.error("can't load http://localhost:3000/test/module.js")
      ).finally(()->
        done()
      )
      $rootScope.$digest();
      return 
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
      expect(array.length).toBe(2)
      expect(array).toContain("highchart-path")
      expect(array).toContain("highchart-ng-path")
      return
    ))
    return
  )
)