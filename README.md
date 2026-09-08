# Vid Horus — Local Short-Video Platform

Vid Horus is a Flutter local-first short-video player designed around a TikTok-style vertical experience. The product deliberately does **not** depend on a backend: videos are selected from the device, persisted locally, and played directly from local files.

## Features

- Vertical swipe feed for local videos.
- Multi-select video import from the device.
- Persistent local library with stale-path cleanup.
- TikTok-style autoplay, pause/play and vertical navigation.
- Double-tap like animation and local counters.
- Long-press 2x playback.
- Horizontal swipe seeking and scrubbable timeline.
- Playback speeds from 0.5x to 2x.
- Loop and mute preferences.
- Cover / contain / fill display modes.
- Immersive landscape fullscreen playback.
- Share the actual local video file through the platform share sheet.
- Remove videos from the app library without deleting the original file.
- Dark, safe-area-aware video-first UI.
- Settings persisted locally and isolated from the player implementation.

## Architecture

- `LocalVideoService` — persistence of selected file paths.
- `VideoProvider` — local feed state and media-library operations.
- `VideoSettingsProvider` — playback preferences.
- `VideoPage` — isolated player surface and controls.
- `FeedScreen` — vertical feed/navigation shell.

The video model supports remote URLs as an extension point, while the current product remains completely local-first.

## Run

```bash
flutter pub get
flutter run
```

## CI / Build

Every push and pull request runs `.github/workflows/build.yml`. The workflow installs the stable Flutter SDK, fetches dependencies, runs static analysis and tests, builds a release Android APK, and uploads the APK as an artifact.

For a local release build:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Backend/auth/cloud-video functionality is intentionally excluded from this stage. The local media boundaries are designed so a future repository, CDN, transcoding, analytics or synchronization layer can be added without replacing the player surface.
