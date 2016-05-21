let filters = angular.module('filters');

filters.filter('ratingToStarCount', function() {
  return function(input) {
    // an input of 95 should return 9
    return Math.round(input / 10);
  };
});
