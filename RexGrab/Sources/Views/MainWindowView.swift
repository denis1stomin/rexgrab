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
            .groupBoxStyle(StandardGroupBoxStyle())
            .padding(.top, 8)

            GroupBox("Quality") {
                QualityPicker(selection: $appState.recordingQuality)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .groupBoxStyle(StandardGroupBoxStyle())

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

/// The system's default GroupBox look uses a fairly large corner radius; this swaps in the
/// standard, smaller radius macOS uses for controls/panels (6pt) while keeping the same label +
/// subtle-fill layout.
private struct StandardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.1))
        )
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

/// Deliberately not a segmented `Picker` (that style is reserved for the video-source chooser in
/// SourceSelectionView) — two plain, directly clickable cards so the two controls read as
/// different kinds of choice at a glance, while the surrounding GroupBox keeps this section
/// aligned with "Choose what to record" above it.
private struct QualityPicker: View {
    @Binding var selection: RecordingQuality

    var body: some View {
        HStack(spacing: 10) {
            ForEach(RecordingQuality.allCases) { quality in
                QualityCard(quality: quality, isSelected: selection == quality) {
                    selection = quality
                }
            }
        }
    }
}

private struct QualityCard: View {
    let quality: RecordingQuality
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(quality.title)
                    .font(.callout.weight(.semibold))
                Text(quality.subtitle)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.85) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? DinoPalette.mid : Color.secondary.opacity(0.1))
            )
            .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}
