import SwiftUI
import PDFKit

struct PresentationView: View {
    let viewModel: PDFViewModel
    @State private var showPageIndicator: Bool = true
    @State private var hideTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let doc = viewModel.pdfDocument,
               let page = doc.page(at: viewModel.currentPageIndex) {
                PresentationPageView(page: page)
                    .id(viewModel.currentPageIndex)
                    .transition(.opacity)
            }

            // Page counter
            if showPageIndicator {
                VStack {
                    Spacer()
                    Text("\(viewModel.currentPageIndex + 1) / \(viewModel.pageCount)")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.5), in: Capsule())
                        .padding(.bottom, 24)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
        .animation(.easeInOut(duration: 0.3), value: showPageIndicator)
        .onAppear { scheduleHideIndicator() }
        .onTapGesture { viewModel.nextPage() }
        .onHover { _ in
            showPageIndicator = true
            scheduleHideIndicator()
        }
        .focusable()
        .onKeyPress(.rightArrow) { viewModel.nextPage(); showAndHide(); return .handled }
        .onKeyPress(.leftArrow) { viewModel.previousPage(); showAndHide(); return .handled }
        .onKeyPress(.space) { viewModel.nextPage(); showAndHide(); return .handled }
        .onKeyPress(.delete) { viewModel.previousPage(); showAndHide(); return .handled }
        .onKeyPress(.escape) { viewModel.exitPresentationMode(); return .handled }
    }

    private func showAndHide() {
        showPageIndicator = true
        scheduleHideIndicator()
    }

    private func scheduleHideIndicator() {
        hideTask?.cancel()
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            showPageIndicator = false
        }
    }
}

// Renders a single PDF page scaled to fit the screen
private struct PresentationPageView: NSViewRepresentable {
    let page: PDFPage

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.backgroundColor = .black
        pdfView.interpolationQuality = .high
        pdfView.displaysPageBreaks = false

        let doc = PDFDocument()
        doc.insert(page, at: 0)
        pdfView.document = doc

        // Remove scroll bars
        if let scrollView = pdfView.subviews.compactMap({ $0 as? NSScrollView }).first {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
        }

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {}
}
