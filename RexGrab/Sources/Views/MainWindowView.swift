import SwiftUI

struct MainWindowView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                DinoBadge()
                Text("RexGrab")
                    .font(.largeTitle.bold())
            }

            GroupBox("Choose what to record") {
                VStack(alignment: .leading, spacing: 14) {
                    RecordingOptionRow(title: "Record video", isOn: $appState.recordVideo)
                    RecordingOptionRow(title: "Record system audio", isOn: $appState.recordSystemAudio)
                    RecordingOptionRow(title: "Record microphone", isOn: $appState.recordMicrophone)
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)

            GroupBox("Quality") {
                QualityPicker(selection: $appState.recordingQuality)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack {
                Spacer()
                Button {
                    appState.primaryButtonTapped()
                } label: {
                    if appState.isLoadingSources {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text(appState.startButtonLabel)
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(appState.isLoadingSources || !appState.recordVideo && !appState.recordSystemAudio && !appState.recordMicrophone)
            }
            .padding(.top, 8)
        }
        .padding(32)
        .frame(width: RexGrabWindowSize.width)
        .dinoThemedBackground()
    }
}

/// A toggle row with the switch on the left and its caption reading to the right of it.
private struct RecordingOptionRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 8) {
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
            Text(title)
        }
    }
}

/// A native macOS radio-button group — the same native control family as the toggle switches
/// above, rather than a custom-drawn card or row. Deliberately not a segmented `Picker` either
/// (that style is reserved for the video-source chooser in SourceSelectionView).
private struct QualityPicker: View {
    @Binding var selection: RecordingQuality

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(RecordingQuality.allCases) { quality in
                Text(quality.title).tag(quality)
            }
        }
        .pickerStyle(.radioGroup)
        .labelsHidden()
    }
}
