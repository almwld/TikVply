# Vid Horus — Local Short-Video Platform

Vid Horus is a Flutter local-first short-video player designed around a TikTok-style vertical experience. The current product deliberately does **not** depend on a backend: videos are selected from the device, persisted locally, and played directly from local files.

## What is implemented

- Vertical swipe feed for local videos.
- Multi-select video import using the native file picker.
- Persistent local video library; invalid/missing paths are cleaned automatically.
- Full-screen portrait playback with optional landscape immersive mode.
- Autoplay on/off.
- Loop on/off.
- Mute/unmute with persistent preference.
- Playback speeds: 0.5x, 0.75x, 1x, 1.25x, 1.5x and 2x.
- Long-press 2x playback when gestures are enabled.
- Horizontal swipe seeking.
- Scrubbable progress bar with current/total duration.
- Three display modes: cover, contain and fill.
- Double-tap like animation.
- Local save/like/share counters.
- Share the actual local video file through the platform share sheet.
- Remove a video from the app library without deleting the original device file.
- Responsive dark video-first UI and safe-area handling.
- Settings are persisted with SharedPreferences and isolated in a dedicated provider so the player can later grow into a larger media platform.

## Architecture

The local media layer is intentionally separated from the UI:

- `LocalVideoService` — persistence of selected file paths.
- `VideoProvider` — local feed state and media-library operations.
- `VideoSettingsProvider` — playback preferences.
- `VideoPage` — isolated player surface and playback controls.
- `FeedScreen` — vertical feed/navigation shell.

The model still supports remote URLs, so a future backend/media CDN can be introduced without redesigning the player surface.

## Run

```bash
flutter pub get
flutter run
```

Tap **+** or the video-library button to select videos from the device.

## Production direction

The project is intentionally local-first. Backend/auth/cloud-video work is excluded from this stage. The separation above leaves clear extension points for a future media repository, transcoding/CDN layer, remote feed, analytics, creator profiles, moderation and synchronization without coupling those concerns to the player.
