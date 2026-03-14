import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.tabbingMode = .preferred
                window.tabbingIdentifier = "pdfClaw"
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
