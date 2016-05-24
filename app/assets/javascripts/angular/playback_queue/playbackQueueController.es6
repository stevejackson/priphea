let controllers = angular.module('controllers');

let playbackQueueController = function($scope, $http, PlaybackQueueService) {
  $scope.playback_queue = null;

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
  ["$scope", "$http", 'PlaybackQueueService', playbackQueueController]
);


