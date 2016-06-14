let controllers = angular.module('controllers');

let settingsController = function($scope, $http) {
  $scope.rescanLibrary = function(deepScan) {
    $http.post('/api/settings/rescan', { deep_scan: deepScan });
  };

  $scope.restartPripheaBackend = function() {
    $http.post('/api/settings/restart_priphea_backend');
  };
};

controllers.controller(
  'SettingsController',
  ['$scope', '$http', settingsController]
);
