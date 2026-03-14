import SwiftUI

@main
struct pdfClawApp: App {
    var body: some Scene {
        DocumentGroup(viewing: PDFFileDocument.self) { config in
            ContentView(document: config.document)
        }
        .commands {
            AppCommands()
        }

        Settings {
            SettingsView()
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @StateObject private var settings = AppSettings()

    var body: some View {
        Form {
            Toggle("Show sidebar on open", isOn: $settings.showSidebarOnOpen)
            Toggle("Restore last position", isOn: $settings.restoreLastPosition)
        }
        .formStyle(.grouped)
        .frame(width: 350)
        .padding()
    }
}
