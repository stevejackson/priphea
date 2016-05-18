let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http, AlbumSelectionService) {
  $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );

  $scope.showAlbum = AlbumSelectionService.setSelectedAlbum;
};

controllers.controller(
  'albumBrowserController',
  ["$scope", "$http", "AlbumSelectionService", albumBrowserController]
);

