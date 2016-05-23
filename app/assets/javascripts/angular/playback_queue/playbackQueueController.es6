let controllers = angular.module('controllers');

let playbackQueueController = function($scope, $http) {
  $scope.playback_queue = null;

  let fetchPlaybackQueue = function() {
    $http.get('/api/songs/playback_queue').
      success(function(data) {
        $scope.playback_queue = data;
      });
  };

  let init = function() {
    fetchPlaybackQueue();
  };

  init();
};

controllers.controller(
  "PlaybackQueueController",
  ["$scope", "$http", playbackQueueController]
);


