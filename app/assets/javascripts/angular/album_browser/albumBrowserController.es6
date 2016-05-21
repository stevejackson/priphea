let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http) {
  $scope.selectedAlbum = null;

  $scope.showAlbum = function(albumId) {
    $http.get(`/api/albums/${albumId}`).
      success(
        function(data) {
          $scope.selectedAlbum = data;
        }
      );
  };

  let fetchAllAlbums = function() {
    $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );
  };

  let init = function() {
    fetchAllAlbums();
  };

  init();

};

controllers.controller(
  'albumBrowserController',
  ["$scope", "$http", albumBrowserController]
);

