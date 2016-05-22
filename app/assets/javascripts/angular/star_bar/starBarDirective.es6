let directives = angular.module("directives");

directives.directive("starBar", function($http) {
  return {
    restrict: 'E',
    templateUrl: 'angular/star_bar/star-bar.html',
    scope: {
      songStarRating: "@",
      songId: "@"
    },
    link: function(scope, elem, attrs) {
      scope.rateSong = function(songId, newRating) {
        let params = {
          song: {
            rating: newRating * 10
          }
        };

        $http.patch(`/api/songs/${songId}`, params).
          success(function(data) {
            scope.songStarRating = newRating;
          });
      };
    }
  };
});
