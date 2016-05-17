let controllers = angular.module('controllers', []);
let directives = angular.module('directives', []);

let albumBrowser = function() {
  return {
    restrict: 'E',
    templateUrl: 'angular/album_browser/albumBrowser.html',
    controller: ['$scope', '$http', albumBrowserController]
  };
};
directives.directive('albumBrowser', albumBrowser);

let albumBrowserController = function($scope, $http) {
  $http.get('/api/albums').
    success(
      function(data) {
        $scope.albums = data;
      }
    );
};
