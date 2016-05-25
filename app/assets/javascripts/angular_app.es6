let priphea = angular.module(
  "priphea",
  [
    // 3rd party dependencies
    'templates', // rails-angular-templates
    'ui.router', // angular-ui-router
    'tableSort', // angular-tablesort
    'ngFileUpload', // ng-file-upload
    // custom modules
    'controllers',
    'directives',
    'services',
    'filters'
  ]
);

let controllers = angular.module('controllers', []);
let directives = angular.module('directives', []);
let services = angular.module('services', []);
let filters = angular.module('filters', []);

priphea.config(function($stateProvider, $urlRouterProvider) {
  $urlRouterProvider.otherwise('/home');

  $stateProvider
    .state('home', {
      url: "/home",
      views: {
        "main-content-area": {
          templateUrl: 'angular/main-content-area.html'
        },
        "content-by-sidebar@home": {
          templateUrl: "angular/album_browser/album_browser.html",
          controller: 'AlbumBrowserController'
        },
        "sidebar@home": {
          templateUrl: "angular/sidebar/sidebar.html"
        }
      }
    })
    .state('home.playbackQueue', {
      url: '/playback_queue',
      views: {
        "content-by-sidebar": {
          templateUrl: "angular/playback_queue/playback_queue.html",
          controller: "PlaybackQueueController"
        }
      }
    })
    .state('albumDetails', {
      url: "/album/:id",
      views: {
        "main-content-area": {
          templateUrl: "angular/album_details/album_details.html",
          controller: "AlbumDetailsController"
        }
      }
    });
});


