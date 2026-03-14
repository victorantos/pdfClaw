import SwiftUI
import PDFKit

struct ToolbarView: View {
    let viewModel: PDFViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Zoom controls
            Button {
                viewModel.zoomOut()
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .help("Zoom Out (⌘-)")

            Text("\(Int(viewModel.scaleFactor * 100))%")
                .monospacedDigit()
                .frame(width: 50)

            Button {
                viewModel.zoomIn()
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .help("Zoom In (⌘+)")

            Divider()
                .frame(height: 16)

            // Page indicator
            Text("Page \(viewModel.currentPageIndex + 1) of \(viewModel.pageCount)")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .font(.callout)

            Divider()
                .frame(height: 16)

            // Sidebar toggle
            Button {
                viewModel.toggleSidebar()
            } label: {
                Image(systemName: "sidebar.left")
            }
            .help("Toggle Sidebar (⇧⌘S)")
        }
    }
}
