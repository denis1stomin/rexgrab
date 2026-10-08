import XCTest
@testable import RexGrab

final class RecordingQualityTests: XCTestCase {
    func testDefaultRecordingSettingsUseOptimalQuality() {
        let settings = RecordingSettings(videoSource: nil, captureSystemAudio: false, captureMicrophone: false)
        XCTAssertEqual(settings.recordingQuality, .optimal)
    }

    func testHighQualityLeavesResolutionAndFrameRateUncapped() {
        XCTAssertNil(RecordingQuality.high.maxVideoDimension)
        XCTAssertNil(RecordingQuality.high.videoFrameRate)
    }

    func testOptimalQualityCapsResolutionAndFrameRate() {
        XCTAssertEqual(RecordingQuality.optimal.maxVideoDimension, 1920)
        XCTAssertEqual(RecordingQuality.optimal.videoFrameRate, 30)
    }

    func testHighQualityUsesStereoAtHigherBitRateThanOptimal() {
        XCTAssertEqual(RecordingQuality.high.audioChannelCount, 2)
        XCTAssertEqual(RecordingQuality.optimal.audioChannelCount, 1)
        XCTAssertGreaterThan(RecordingQuality.high.audioBitRate, RecordingQuality.optimal.audioBitRate)
    }
}
