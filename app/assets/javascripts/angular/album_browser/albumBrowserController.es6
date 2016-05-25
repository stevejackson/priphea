let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http, SongQueuerService) {
  $scope.albums = [];
  $scope.selectedAlbum = null;

  $scope.showAlbum = function(albumId) {
    $http.get(`/api/albums/${albumId}`).
      success(
        function(data) {
          $scope.selectedAlbum = data;
        }
      );
  };

  $scope.queueFromSong = SongQueuerService.queueFromSong;

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
  'AlbumBrowserController',
  ["$scope", "$http", 'SongQueuerService', albumBrowserController]
);
