let controllers = angular.module('controllers');

let showSmartPlaylistController = function($scope, $http, $stateParams, SongQueuerService) {
  $scope.smartPlaylist = null;

  $scope.queueFromSong = SongQueuerService.queueFromSong;

  let fetchSmartPlaylist = function() {
    $http.get(`/api/smart_playlists/${$stateParams.id}`).success(function(data) {
        $scope.smartPlaylist = data;
      });
  };

  let init = function() {
    fetchSmartPlaylist();
  };

  init();
};

controllers.controller(
  "ShowSmartPlaylistController",
  ["$scope", "$http", "$stateParams", 'SongQueuerService', showSmartPlaylistController]
);


