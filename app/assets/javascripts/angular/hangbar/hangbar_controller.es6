let controllers = angular.module('controllers');

let hangbarController = function($scope, $http, $interval, PlaybackQueueService, $state) {
  $scope.volume = null;
  $scope.nowPlayingStatus = null;
  $scope.nowPlayingSong = null;
  $scope.searchKeywords = null;

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

  $scope.search = function() {
    $state.go("home.search", { keywords: $scope.searchKeywords });
  };

  $scope.seekToPosition = function($event) {
    let element = angular.element($event.target);

    let mouseClickX = $event.offsetX;
    let barWidth = element.width();
    let seekPercentage = (mouseClickX / barWidth) * 100.0;

    $http.post('/api/player/seek', { percent: seekPercentage });
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
    $interval(fetchNowPlaying, 500);
  };

  init();
};

controllers.controller(
  'HangbarController',
  ['$scope', '$http', '$interval', 'PlaybackQueueService', "$state", hangbarController]
);
