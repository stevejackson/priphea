let controllers = angular.module('controllers');

let playbackQueueController = function($scope, $http, PlaybackQueueService, SongQueuerService) {
  $scope.playback_queue = null;

  $scope.queueFromSong = SongQueuerService.queueFromSong;

  let fetchPlaybackQueue = function() {
    PlaybackQueueService.getPlaybackQueue().
      then(function(response) {
        $scope.playback_queue = response.data;
      });
  };

  let init = function() {
    fetchPlaybackQueue();
  };

  init();
};

controllers.controller(
  "PlaybackQueueController",
  ["$scope", "$http", 'PlaybackQueueService', 'SongQueuerService', playbackQueueController]
);


