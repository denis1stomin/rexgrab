# How RexGrab works

The design decisions behind RexGrab, for contributors. Worth a skim before proposing a significant change.
Known issues are in [`RELEASE_NOTES.md`](../RELEASE_NOTES.md).

## The app

A native Swift app (SwiftUI/AppKit) with a regular Dock icon, for the latest macOS (deployment target 26.0),
built as a universal binary (arm64 + x86_64). There is no menu bar icon: macOS's own recording indicator already
shows that capture is active.

### UX flow

1. **First window** (on launch): toggles for *Record video*, *Record system audio* and *Record microphone*, the
   quality cards (*Optimal*, the default, and *Native*) and a start button. Its caption follows the video toggle:
   **Select video source** when video is on, **Start recording only audio** when it is off.
2. **Source window** (video only): record the **whole screen** (a preview per display; one display at a time) or a
   **specific app window** (window previews), then **Start Recording**.
3. **Recording**: the app window hides; macOS shows its own capture indicator.
4. Clicking the Dock icon or Cmd+Tab while recording opens the **processing window**: what is being recorded, a
   timer, **Pause** and **Stop**.

Every path that ends a recording (Stop, or an automatic stop) saves the file to **Downloads**, opens that folder in
Finder and returns to the first window. If the recorded window closes or its app crashes, the recording stops and
saves the same way.

Pause stops both video and audio, so the output has no frozen frames or dead air.

## Capture and encoding

ScreenCaptureKit delivers sample buffers that go straight into `AVAssetWriter` with hardware H.264 encoding
(VideoToolbox), encoded on the fly, not captured raw and converted later. Hardware encoding stays light next to
a video-meeting app's own CPU/GPU use. The main code is `RexGrab/Sources/Capture/RecordingManager.swift`.

- **Output:** MP4 (H.264), named `Recording YYYY-MM-DDTHH-MM-SS.mp4` (hyphens, since `:` is unsafe in macOS file
  names). On a name clash, a Finder-style ` (2)`, ` (3)` is added.
- **Any combination** of video, system audio and microphone works, including audio only.
- **Audio tracks:** microphone and system audio are **separate tracks**, not mixed, so each can be muted or edited
  on its own.
- **System audio scope:** for a window recording, only that app's audio; for a whole screen, all system audio.
  RexGrab's own audio is always excluded.
- **Segments:** long recordings roll over to a new file every **1.5 hours**. Memory stays flat either way (samples
  stream to disk); the split is for resilience, since a file being written when the app dies can end up unplayable.

### Quality presets (`RecordingQuality.swift`)

| Preset | Video | Audio |
|---|---|---|
| **Optimal** (default) | longer edge capped at 1920 px, aspect ratio kept; at most 30 fps; H.264 High profile | mono AAC, 64 kbps |
| **Native** | native resolution and frame rate | stereo AAC, 128 kbps |

Optimal files are smaller because of the resolution and frame-rate caps, not because of lower encoding quality.
No explicit video bitrate is set: `AVVideoAverageBitRateKey` is only a soft target that VideoToolbox undershoots on
mostly static screen content, and its own complexity-adaptive default looks better. Note that
`maxVideoDimension` caps the **longer edge**: 1920 gives real 1080p on a 16:9 screen, while 1080 would give about
1080×608.

The two presets are plain clickable cards, not a segmented control: that style is kept for the screen/window choice,
so the two pickers read as different kinds of choice.

### Window resizing during a recording

When a recorded window's content resizes (a video goes full screen, the user drags the window), the encoder size
must follow, or the output shows the new content inside a black frame. In window mode, RexGrab polls
`SCShareableContent` every 1.5 s for the window's real frame (ScreenCaptureKit's per-frame metadata is relative to
the stream's current size, so it can't tell when that size is stale). Two matching polls and a 64 px minimum are
needed before acting; then the stream is updated with `SCStream.updateConfiguration` and recording rolls over to a
new segment. Whole-screen mode doesn't poll: a display's size doesn't change mid-recording.

## Permissions and sandbox

- On first use, RexGrab triggers the **native macOS prompts** for Screen Recording (by calling
  `SCShareableContent.current`) and Microphone (`AVCaptureDevice.requestAccess(for: .audio)`). Only after a denial
  does it show its own alert explaining how to re-enable access in System Settings.
- **App Sandbox is on**, with `com.apple.security.files.downloads.read-write` (save to Downloads without a file
  picker) and `com.apple.security.device.audio-input`. It limits what the app can reach and keeps an App Store
  submission possible. The entitlements work with ad-hoc signing.

## Distribution and signing

- **GitHub Releases**, built by `.github/workflows/release.yml` on a `v*` tag: a `Release` archive, ad-hoc signed,
  zipped and published. A tag with a hyphen (`v1.0.0-rc.1`) is a prerelease.
- **No Apple Developer ID** for now, so no notarization: users see a Gatekeeper warning and open the app with
  right-click → Open.
- **Build provenance:** the release zip is attested with `actions/attest-build-provenance`; verify a download with
  `gh attestation verify`. This proves the zip was built by this repo's workflow from the tagged commit; it is not a
  malware scan.
- **Homebrew:** `brew install --cask denis1stomin/rexgrab/rexgrab` (tap repo `denis1stomin/homebrew-rexgrab`). The
  quarantine flag stays set on cask installs, so the Gatekeeper step remains.

## Project and tests

- A normal, committed `RexGrab.xcodeproj` (no generator). Per-user Xcode state (`xcuserdata`) is git-ignored.
- **`RexGrabUnitTests`** (`make test`): pure logic (file naming, segment timing, the start-button label). CI runs it
  on every push and pull request.
- **`RexGrabDesktopTests`** (`make test-desktop`): real short recordings through ScreenCaptureKit/AVFoundation,
  checked for a playable MP4 with the expected tracks. It needs Screen Recording and Microphone permission on a real
  desktop, so it runs locally only, not in CI.
- **CI:** GitHub Actions on the `macos-26` runner (the first with Xcode 26 and the macOS 26 SDK; `macos-15` can't
  build for deployment target 26.0). **CodeQL** (Swift) runs in its own workflow on push, pull request and weekly.
