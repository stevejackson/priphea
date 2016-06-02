let controllers = angular.module('controllers');

let settingsController = function($scope, $http) {
  $scope.rescanLibrary = function(deepScan) {
    $http.post('/api/settings/rescan', { deep_scan: deepScan });
  };
};

controllers.controller(
  'SettingsController',
  ['$scope', '$http', settingsController]
);
