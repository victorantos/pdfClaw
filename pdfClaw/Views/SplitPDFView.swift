import SwiftUI
import PDFKit

struct SplitPDFView: View {
    let primaryViewModel: PDFViewModel
    @State private var secondaryViewModel = PDFViewModel()
    @State private var syncScroll: Bool = false
    @State private var showFilePicker: Bool = false

    var body: some View {
        HSplitView {
            PDFKitView(viewModel: primaryViewModel)
                .frame(minWidth: 200)

            VStack {
                if secondaryViewModel.pdfDocument != nil {
                    HStack {
                        Toggle("Sync scroll", isOn: $syncScroll)
                            .toggleStyle(.switch)
                            .controlSize(.small)
                        Spacer()
                        Button("Close") {
                            secondaryViewModel.pdfDocument = nil
                        }
                        .controlSize(.small)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    PDFKitView(viewModel: secondaryViewModel)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("Open a PDF to compare")
                            .foregroundStyle(.secondary)
                        Button("Choose File…") {
                            showFilePicker = true
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 200)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf]
        ) { result in
            if case .success(let url) = result {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url) {
                        secondaryViewModel.loadDocument(from: data)
                    }
                }
            }
        }
        .onChange(of: syncScroll) { _, newValue in
            if newValue {
                setupScrollSync()
            }
        }
    }

    private func setupScrollSync() {
        guard syncScroll,
              let primaryPdfView = primaryViewModel.pdfView,
              let secondaryPdfView = secondaryViewModel.pdfView,
              let primaryScroll = primaryPdfView.subviews.compactMap({ $0 as? NSScrollView }).first,
              let secondaryScroll = secondaryPdfView.subviews.compactMap({ $0 as? NSScrollView }).first else { return }

        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: primaryScroll.contentView,
            queue: .main
        ) { _ in
            guard self.syncScroll else { return }
            let origin = primaryScroll.contentView.bounds.origin
            secondaryScroll.contentView.scroll(to: origin)
            secondaryScroll.reflectScrolledClipView(secondaryScroll.contentView)
        }
    }
}
