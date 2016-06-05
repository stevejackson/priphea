let controllers = angular.module('controllers');

let albumBrowserController = function($scope, $http, SongQueuerService, $stateParams, $timeout) {
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
    let params = null;

    if($stateParams.keywords) {
      params = {
        "query": $stateParams.keywords
      };
    }

    $http.get('/api/albums', { params: params, cache: true }).
      success(
        function(data) {
          $scope.albums = data;
        }
      );
  };

  $scope.$watch("albums", function(value) {
      if ($stateParams.showAlbum) {
        $timeout(function() {
          var elementToShow = $(`#album-anchor-${$stateParams.showAlbum}`);
          var scrollTop = elementToShow.position().top;

          $("#cover_art_gallery").animate({
            scrollTop: scrollTop
          }, "slow");
        }, 400);
      }
    }
  );

  let init = function() {
    fetchAllAlbums();
  };

  init();
};

controllers.controller(
  'AlbumBrowserController',
  ["$scope", "$http", 'SongQueuerService', "$stateParams", "$timeout", albumBrowserController]
);
