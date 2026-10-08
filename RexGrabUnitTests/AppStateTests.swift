import XCTest
@testable import RexGrab

@MainActor
final class AppStateTests: XCTestCase {
    func testCurrentSettingsCarriesSelectedRecordingQuality() {
        let appState = AppState()

        XCTAssertEqual(appState.currentSettings.recordingQuality, .optimal, "default should be optimal")

        appState.recordingQuality = .high
        XCTAssertEqual(appState.currentSettings.recordingQuality, .high)

        appState.recordingQuality = .optimal
        XCTAssertEqual(appState.currentSettings.recordingQuality, .optimal)
    }
}
