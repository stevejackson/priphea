let controllers = angular.module("controllers");

let albumSongListController = function($scope, $http, AlbumSelectionService) {
  $scope.$watch(
    function() {
      return AlbumSelectionService.getSelectedAlbum();
    },
    function(value) {
      $scope.fetchSongsOfAlbum(value);
    }
  );

  $scope.fetchSongsOfAlbum = function(albumId) {
    $http.get(`/api/albums/${albumId}`).
      success(
        function(data) {
          $scope.album = data;
        }
      );
  }
};

controllers.controller(
  "albumSongListController",
  ["$scope", "$http", 'AlbumSelectionService', albumSongListController]
);

