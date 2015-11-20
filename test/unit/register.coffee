normal = "normal"
test = "lazy"
normalRun = false
angular.module("normal.test",['ng','angular.lazy.register'])
.service("normalService",()->
  return {msg:normal}
)
.provider("normalProvider",()->
  @name = 'normal'
  @$get = ()->
    return {msg:normal}
  return @
)
.factory("normalFactory",()->
  return {msg:normal}
)
.value("normalValue",normal)
.constant("normalConstant",normal)
.filter("normalFilter",()->
  return (c)->
    return "normal#{c}"
)
.controller("normalCtrl",()->
  @name = normal
  return @
)
.directive("ndr",()->
  return {
    restrict:"A"
    link:(scope)->
      scope.name = normal
      return
  }
)
.config((normalProviderProvider)->
  normalProviderProvider.name = 'config'
  return normalProviderProvider
)
.run(()->
  normalRun = true
)

describe("register",()->
  beforeEach(module("normal.test"))
  beforeAll(()->
    register = angular.module("angular.lazy.register") 
    register.isBootstrap = true
  )
  moduleName = "test.lazy"
  describe("module",()->
    nextModuleName = "test.require"
    it("lazy register",inject(()->
      m = angular.module(moduleName,['ng'])
      msg = "it only test"
      expect(m).toBe(angular.module(moduleName))
      return 
    ))
    it("add require",inject(()->
      r = angular.module(nextModuleName,['ng'])
      m = angular.module(moduleName,[nextModuleName])
      expect(m.requires).toContain(nextModuleName)
      return
    ))
  )
  describe("service",()->
    it("normal",inject((normalService)->
      # expect(normalService).toBeDefined()
      expect(normalService.msg).toBe(normal)
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      m.service("testService",()->
        return {msg:test}
      )
      inject((testService)->
        expect(testService.msg).toBe(test)
      )
    ))
  )
  describe("provider",()->
    it("normal",inject((normalProvider)->
      expect(normalProvider.msg).toBe(normal)  
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      m.provider("testProvider",()->
        @name = test
        @$get = ()->
          return {msg:test}
        return @
      )
      inject((testProvider)->
        expect(testProvider.msg).toBe(test)
      )
    ))
  )
  describe('factory',()->
    it("normal",inject((normalFactory)->
      expect(normalFactory.msg).toBe(normal)  
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      m.factory("testFactory",()->
        return {msg:test}
      )
      inject((testFactory)->
        expect(testFactory.msg).toBe(test)
      )
    ))
  )
  describe('value',()->
    it("normal",inject((normalValue)->
      expect(normalValue).toBe(normal)  
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      m.value("testValue",test)
      inject((testValue)->
        expect(testValue).toBe(test)
      )
    ))
  )
  describe('constant',()->
    it("normal",inject((normalConstant)->
      expect(normalConstant).toBe(normal)  
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      m.constant("testConstant",test)
      inject((testConstant)->
        expect(testConstant).toBe(test)
      )
    ))
  )
  describe("animation",()->
    ;
  )
  describe("filter",()->
    it("normal",inject(($filter)->
      expect($filter("normalFilter")).not.toBeNull()
    ))
    it("lazy",inject(($filter)->
      m = angular.module(moduleName)
      m.filter("testFilter",()->
        return angular.noop
      )
      expect($filter("testFilter")).not.toBeNull()
    ))
  )
  describe("controller",()->
    it("normal",inject(($controller)->
      normalCtrl = $controller("normalCtrl",{})
      expect(normalCtrl.name).toBe(normal)
    ))
    it("lazy",inject(($controller)->
      m = angular.module(moduleName)
      m.controller("testController",()->
        @name = test
        return @
      )
      testCtrl = $controller("testController",{})
      expect(testCtrl.name).toBe(test)
    ))
  )
  describe("directive",()->
    it("normal",inject(($compile, $rootScope)->
      scope =  $rootScope.$new()
      link = $compile('<div ndr></div>')
      link(scope)
      expect(scope.name).toBe(normal)
    ))
    it("lazy",inject(($compile, $rootScope)->
      m = angular.module(moduleName)
      m.directive('tdr',()->
        return {
          restrict:"A"
          link:(scope)->
            scope.name = test
            return
        }
      )
      scope =  $rootScope.$new()
      link = $compile('<div tdr></div>')
      link(scope)
      expect(scope.name).toBe(test)
    ))
  )
  describe("config",()->
    normalProvider = null
    beforeEach(module((normalProviderProvider)->
      normalProvider = normalProviderProvider
      return;
    ))
    it("normal",inject(()->
      expect(normalProvider.name).toBe("config")
    ))
    it("lazy",inject(()->
      m = angular.module(moduleName)
      isRunConfig = false
      m.provider("testProvider2",()->
        @name = test
        @$get = ()->
          return {msg:test}
        return @
      ).config((testProvider2Provider)->
        isRunConfig = true
      )
      expect(isRunConfig).toBeTruthy()
    ))
  )
  describe("run",()->
    it("normal",inject(()->
      expect(normalRun).toBeTruthy()
    ))
    it("lazy",(done)->
      inject(()->
        angular.module(moduleName).run(()->
          done()
        )
      )
    )
    # 正常情况从rootElement种能够拿刀inject，而测试时拿不到
    # it("mini",inject(()->
    #   m = angular.module("normal.test")
    #   isRun = false
    #   m.service("$runService",()->
    #     return {}
    #   )
    #   m.run(['register',(register)->
    #     isRun = true
    #   ])
    #   expect(isRun).toBeTruthy()
    # ))
  )

  describe("enableDistinst",()->
    provider = null;
    beforeEach(module((registerProvider)->
      provider = registerProvider
      expect(provider).toBeDefined()
      return
    ))
    it("service",inject(()->
      provider.enableDistinst =  true
      m = angular.module(moduleName)
      service1 = ()->
        @name = 'service1'
        return @
      service2 = ()->
        @name = "service2"
        return @
      m.service("someService",service1)
      m.service("someService",service2)
      inject((someService)->
        expect(someService.name).toBe("service1")
      )
    ))
    describe("directive",()->
      it("mutli",inject(($compile, $rootScope)->
        m = angular.module(moduleName)
        num = 0
        m.directive("sm",()->
          return {
            restrict:"A"
            link:(scope)->
              num++
              return
          }
        ).directive("sm",()->
          return {
            restrict:"A"
            link:(scope)->
              'smthing other'
              num++
              return
          }
        )
        scope =  $rootScope.$new()
        link = $compile('<div sm></div>')
        link(scope)
        console.log(num)
        expect(num).toBe(2)
      ))

      it("once",inject(($compile, $rootScope)->
        provider.enableDistinst =  true
        m = angular.module(moduleName)
        num = 0
        d = ()->
          return {
            restrict:"A"
            link:(scope)->
              num++
              return
          }
        m.directive("sm2",d).directive("sm2",d)
        scope =  $rootScope.$new()
        link = $compile('<div sm2></div>')
        link(scope)
        console.log(num)
        expect(num).toBe(1)
      ))
      return
    )
  )
  return 
)
