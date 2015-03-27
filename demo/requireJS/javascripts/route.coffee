define(['angular','app','uiRouter','controller/second'],(ng,app)->
  app.config [
    "$stateProvider"
    "$urlRouterProvider"
    "$locationProvider"
    ($stateProvider, $urlRouterProvider,$locationProvider)->
      $locationProvider.html5Mode(true)
      # $urlRouterProvider.otherwise "view1"
      $stateProvider.state("view1",
        url: "/view1"
        templateUrl: "templates/view1.html"
        controller:"firstCtrl"
        resolve:
          ctrl:($q)->
            deferred = $q.defer()
            require(['controller/first'],(ctrl)->
              deferred.resolve()
            ,(err)->
              console.log 'error',err
              deferred.reject(err)
            )
            return deferred.promise
      ).state("view2",
        url: "/view2"
        templateUrl: "templates/view2.html"
        controller:"secondCtrl"
      )
  ]
)