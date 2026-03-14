import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    let viewModel: PDFViewModel

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .controlBackgroundColor
        pdfView.interpolationQuality = .high

        viewModel.pdfView = pdfView
        context.coordinator.observe(pdfView: pdfView)

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        if viewModel.pdfView !== pdfView {
            viewModel.pdfView = pdfView
            context.coordinator.observe(pdfView: pdfView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    final class Coordinator: NSObject {
        let viewModel: PDFViewModel
        private var observations: [NSObjectProtocol] = []

        init(viewModel: PDFViewModel) {
            self.viewModel = viewModel
        }

        func observe(pdfView: PDFView) {
            observations.forEach { NotificationCenter.default.removeObserver($0) }
            observations.removeAll()

            let pageObs = NotificationCenter.default.addObserver(
                forName: .PDFViewPageChanged,
                object: pdfView,
                queue: .main
            ) { [weak self] _ in
                self?.viewModel.syncPageIndex()
                self?.viewModel.saveCurrentPosition()
            }

            let scaleObs = NotificationCenter.default.addObserver(
                forName: .PDFViewScaleChanged,
                object: pdfView,
                queue: .main
            ) { [weak self] _ in
                self?.viewModel.syncScale()
            }

            // Observe scroll for adaptive interpolation
            if let scrollView = pdfView.subviews.compactMap({ $0 as? NSScrollView }).first {
                let scrollBeganObs = NotificationCenter.default.addObserver(
                    forName: NSScrollView.willStartLiveScrollNotification,
                    object: scrollView,
                    queue: .main
                ) { [weak self] _ in
                    self?.viewModel.onScrollBegan()
                }

                let scrollEndedObs = NotificationCenter.default.addObserver(
                    forName: NSScrollView.didEndLiveScrollNotification,
                    object: scrollView,
                    queue: .main
                ) { [weak self] _ in
                    self?.viewModel.onScrollEnded()
                }

                observations = [pageObs, scaleObs, scrollBeganObs, scrollEndedObs]
            } else {
                observations = [pageObs, scaleObs]
            }
        }

        deinit {
            observations.forEach { NotificationCenter.default.removeObserver($0) }
        }
    }
}
