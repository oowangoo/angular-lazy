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
  it("load",(done)->
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
)