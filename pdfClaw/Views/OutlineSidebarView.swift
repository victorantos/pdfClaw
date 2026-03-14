import SwiftUI
import PDFKit

struct OutlineSidebarView: View {
    let outline: PDFOutline?
    let viewModel: PDFViewModel

    var body: some View {
        if let outline, outline.numberOfChildren > 0 {
            List {
                OutlineNodeView(node: outline, viewModel: viewModel, isRoot: true)
            }
            .listStyle(.sidebar)
        } else {
            ContentUnavailableView(
                "No Table of Contents",
                systemImage: "list.bullet",
                description: Text("This document has no outline.")
            )
        }
    }
}

private struct OutlineNodeView: View {
    let node: PDFOutline
    let viewModel: PDFViewModel
    let isRoot: Bool

    var body: some View {
        ForEach(0..<node.numberOfChildren, id: \.self) { index in
            if let child = node.child(at: index) {
                if child.numberOfChildren > 0 {
                    DisclosureGroup {
                        OutlineNodeView(node: child, viewModel: viewModel, isRoot: false)
                    } label: {
                        outlineLabel(for: child)
                    }
                } else {
                    outlineLabel(for: child)
                }
            }
        }
    }

    @ViewBuilder
    private func outlineLabel(for item: PDFOutline) -> some View {
        Button {
            if let dest = item.destination, let page = dest.page {
                viewModel.pdfView?.go(to: page)
            }
        } label: {
            Text(item.label ?? "Untitled")
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
