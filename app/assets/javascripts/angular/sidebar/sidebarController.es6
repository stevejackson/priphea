let controllers = angular.module('controllers');

let sidebarController = function($scope, $http) {
  $scope.smartPlaylists = [];

  let fetchSmartPlaylists = function() {
    $http.get('/api/smart_playlists').success(function(data) {
        $scope.smartPlaylists = data;
      });
  };

  let init = function() {
    fetchSmartPlaylists();
  };

  init();
};

controllers.controller(
  'SidebarController',
  ['$scope', '$http', sidebarController]
);
