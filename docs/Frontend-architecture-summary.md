# Summary

This document provides an overview to how the frontend is structured.

## Components

The web app is a single-page application.

### Shared components between all pages:

- **Hangbar** - the topmost bar that stays visible at all times, showing the currently playing song, search controls, and pause/play buttons.
  - AudioPlayerController - handle pause/play/volume, etc
  - NowPlayingController
  - SearchController
    - SearchService - watched by AlbumBrowserController, when search value changes, the albums displayed will update

### Pages:

- **Song browser** -
  - AlbumBrowserController
    - shows cover art browser list (also takes SearchService into account in case user is currently searching)
    - shows table of a specific album's songs
  - SidebarController - display sidebar of playlists, etc
  - PlaybackQueueController - display a table of currently queued songs
  - SmartPlaylistController - display a table of smart playlist songs
- **Album details view** - options to edit a given album's metadata, change album art, etc.
- **Priphea settings view** - options to rescan entire library, etc.
- **Smart playlist details view** - create and edit smart playlists
