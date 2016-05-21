let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http) {
  $scope.selectedAlbum = null;

  $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );

  $scope.showAlbum = function(albumId) {
    $http.get(`/api/albums/${albumId}`).
      success(
        function(data) {
          $scope.selectedAlbum = data;
        }
      );
  }
};

controllers.controller(
  'albumBrowserController',
  ["$scope", "$http", albumBrowserController]
);

