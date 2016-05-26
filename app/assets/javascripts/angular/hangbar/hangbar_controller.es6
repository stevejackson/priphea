let controllers = angular.module('controllers');

let hangbarController = function($scope, $http, $interval, PlaybackQueueService) {
  $scope.volume = null;
  $scope.nowPlayingStatus = null;
  $scope.nowPlayingSong = null;

  $scope.resume = function() {
    $http.post('/api/player/resume');
  };

  $scope.pause = function() {
    $http.post('/api/player/pause');
  };

  $scope.nextSong = function() {
    $http.post('/api/player/next_song');
  };

  $scope.updateVolume = function() {
    let params = { volume: $scope.volume };
    $http.post('/api/player/set_volume', params);
  };

  let fetchNowPlaying = function() {
    $http.get('/api/player/update_and_get_status')
      .success(function(data) {
        $scope.nowPlayingStatus = data;
        $scope.nowPlayingSong = data.song;
        $scope.volume = $scope.nowPlayingStatus.volume;
      });
  };

  let init = function() {
    $interval(fetchNowPlaying, 250);
  };

  init();
};

controllers.controller(
  'HangbarController',
  ['$scope', '$http', '$interval', 'PlaybackQueueService', hangbarController]
);
