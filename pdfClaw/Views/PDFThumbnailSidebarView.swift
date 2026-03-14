import SwiftUI
import PDFKit

struct PDFThumbnailSidebarView: NSViewRepresentable {
    let pdfView: PDFView?

    func makeNSView(context: Context) -> PDFThumbnailView {
        let thumbnailView = PDFThumbnailView()
        thumbnailView.thumbnailSize = CGSize(width: 120, height: 160)
        thumbnailView.backgroundColor = .controlBackgroundColor
        if let pdfView {
            thumbnailView.pdfView = pdfView
        }
        return thumbnailView
    }

    func updateNSView(_ thumbnailView: PDFThumbnailView, context: Context) {
        if let pdfView, thumbnailView.pdfView !== pdfView {
            thumbnailView.pdfView = pdfView
        }
    }
}
