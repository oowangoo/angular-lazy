angular.module("normal").config [
  "$stateProvider"
  "$urlRouterProvider"
  "$locationProvider"
  ($stateProvider, $urlRouterProvider,$locationProvider)->
    $locationProvider.html5Mode(true)
    $urlRouterProvider.otherwise "view1"
    $stateProvider.state("index",
      url: "/view1"
      templateUrl: "templates/view1.html"
      controller:"indexCtrl"
    ).state("indexLazy",
      url: "/view2"
      templateUrl: "templates/view2.html"
      controller:"indexLazyCtrl"
    )

]