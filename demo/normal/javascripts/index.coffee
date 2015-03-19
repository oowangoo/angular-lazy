# Name Module
#
# @abstract Description
#
window.app = angular.module('normal', ['ng','angular.lazy','ui.router']).controller('indexCtrl',['$scope',($scope)->
  $scope.text = '1111111111111111'
  return ;
]).controller("indexLazyCtrl",($scope)->
  $scope.text = 'lazy'
  return ;
)