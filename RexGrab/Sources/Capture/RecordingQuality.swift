import AVFoundation

/// User-selectable quality preset, picked on the first window (default: optimal).
///
/// `.high` reproduces RexGrab's original, pre-tightening behavior: no resolution or frame-rate
/// cap and VideoToolbox's own complexity-adaptive bitrate — exactly the settings that produced
/// the ~2.4 GB/70-minute full-screen recording described in RELEASE_NOTES.md. `.optimal` is the
/// fix that came out of that real-world testing, carried over unchanged as this preset's values
/// since it was already validated: cap the pixels/frames fed to the adaptive encoder instead of
/// fighting its bitrate rate control (see RecordingManager's own comments on why an explicit
/// `AVVideoAverageBitRateKey` made things blurrier, not smaller) — the same "let a
/// complexity-adaptive encoder do the work, don't force a fixed target" principle behind the
/// crf-driven re-encodes in `video_encoding_params.md`, translated to RexGrab's hardware
/// VideoToolbox pipeline rather than that doc's software libx264 settings (there's no direct crf
/// equivalent for on-the-fly H.264 hardware encoding).
enum RecordingQuality: String, CaseIterable, Identifiable, Equatable {
    case high
    case optimal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .high: return "High Quality"
        case .optimal: return "Optimal"
        }
    }

    var subtitle: String {
        switch self {
        case .high: return "Native resolution — large files"
        case .optimal: return "Smaller files, built for meetings"
        }
    }

    /// Caps the *longer* edge of the captured video to this many pixels; nil records at the
    /// source's native resolution. Note this is the longer edge, not height specifically — 1080
    /// here would NOT mean "1080p": for a 16:9 screen it would land at roughly 1080x608
    /// (~600p-equivalent, a third of 1080p's real pixel count). 1920 gives real 1920x1080 for a
    /// standard 16:9 screen, which is what "1080p" actually refers to — this units mix-up
    /// previously caused a real blurry-video report that looked like a bitrate problem at first.
    var maxVideoDimension: Int? {
        switch self {
        case .high: return nil
        case .optimal: return 1920
        }
    }

    /// Caps frames per second; nil lets ScreenCaptureKit deliver at the display's own refresh
    /// rate (up to 120Hz on ProMotion).
    var videoFrameRate: Double? {
        switch self {
        case .high: return nil
        case .optimal: return 30
        }
    }

    /// nil leaves the H.264 profile/level up to VideoToolbox's own default.
    var videoProfileLevel: String? {
        switch self {
        case .high: return nil
        case .optimal: return AVVideoProfileLevelH264HighAutoLevel
        }
    }

    var audioChannelCount: Int {
        switch self {
        case .high: return 2
        case .optimal: return 1
        }
    }

    var audioBitRate: Int {
        switch self {
        case .high: return 128_000
        case .optimal: return 64_000
        }
    }
}
