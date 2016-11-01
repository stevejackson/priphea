let controllers = angular.module('controllers');

let settingsController = function($scope, $http) {
  $scope.rescanLibrary = function(deepScan) {
    $http.post('/api/settings/rescan', { deep_scan: deepScan });
  };

  $scope.rescanLibrary = function(deepScan) {
    $http.post('/api/settings/rescan', { deep_scan: deepScan });
  };

  $scope.updateCoverArtCache = function() {
    $http.post('/api/settings/update_cover_art_cache');
  };
};

controllers.controller(
  'SettingsController',
  ['$scope', '$http', settingsController]
);
