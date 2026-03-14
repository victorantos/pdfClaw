import SwiftUI
import UniformTypeIdentifiers

struct WelcomeView: View {
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("pdfClaw")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Open a PDF to get started")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Drag & drop a PDF here, or use File → Open")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        .overlay {
            if isTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .padding(8)
            }
        }
        .onDrop(of: [.pdf], isTargeted: $isTargeted) { providers in
            // DocumentGroup handles file opening, this is just visual feedback
            return false
        }
    }
}
