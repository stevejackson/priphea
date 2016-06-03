let priphea = angular.module(
  "priphea",
  [
    // 3rd party dependencies
    'templates', // rails-angular-templates
    'ui.router', // angular-ui-router
    'tableSort', // angular-tablesort
    'ngFileUpload', // ng-file-upload
    'angularLazyImg', // angular-lazy-img
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
          templateUrl: "angular/sidebar/sidebar.html",
          controller: 'SidebarController'
        }
      }
    })
    .state('home.search', {
      url: "/search/:keywords",
      views: {
        "content-by-sidebar": {
          templateUrl: "angular/album_browser/album_browser.html",
          controller: 'AlbumBrowserController'
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
    .state('home.albumDetails', {
      url: "/album/:id",
      views: {
        "content-by-sidebar": {
          templateUrl: "angular/album_details/album_details.html",
          controller: "AlbumDetailsController"
        }
      }
    })
    .state('home.showSmartPlaylist', {
      url: "/smart_playlist/:id",
      views: {
        "content-by-sidebar": {
          templateUrl: "angular/smart_playlists/show_smart_playlist.html",
          controller: "ShowSmartPlaylistController"
        }
      }
    })
    .state('home.settings', {
      url: '/settings',
      views: {
        "content-by-sidebar": {
          templateUrl: "angular/settings/settings.html",
          controller: "SettingsController"
        }
      }
    });
});


