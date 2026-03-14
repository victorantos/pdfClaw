import SwiftUI
import PDFKit

struct KeyboardHandler: NSViewRepresentable {
    let viewModel: PDFViewModel

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.viewModel = viewModel
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.viewModel = viewModel
    }
}

final class KeyCaptureView: NSView {
    var viewModel: PDFViewModel?
    private var lastGTime: Date?
    private let scrollAmount: CGFloat = 50

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard let viewModel, let chars = event.charactersIgnoringModifiers else {
            super.keyDown(with: event)
            return
        }

        // Don't capture keys when search bar is focused
        if viewModel.showSearch || viewModel.showGoToPage {
            super.keyDown(with: event)
            return
        }

        switch chars {
        case "j":
            viewModel.scrollBy(dx: 0, dy: scrollAmount)
        case "k":
            viewModel.scrollBy(dx: 0, dy: -scrollAmount)
        case "d":
            viewModel.halfPageDown()
        case "u":
            viewModel.halfPageUp()
        case "h":
            viewModel.scrollBy(dx: -scrollAmount, dy: 0)
        case "l":
            viewModel.scrollBy(dx: scrollAmount, dy: 0)
        case "G":
            viewModel.goToLastPage()
        case "g":
            let now = Date()
            if let last = lastGTime, now.timeIntervalSince(last) < 0.5 {
                viewModel.goToFirstPage()
                lastGTime = nil
            } else {
                lastGTime = now
            }
        case "/":
            viewModel.showSearch = true
        case "n":
            viewModel.nextSearchResult()
        case "N":
            viewModel.previousSearchResult()
        case "q":
            if viewModel.showSearch {
                viewModel.clearSearch()
            }
        default:
            super.keyDown(with: event)
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Pass through mouse events to views underneath
        return nil
    }
}
