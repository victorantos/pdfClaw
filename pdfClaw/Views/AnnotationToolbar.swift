import SwiftUI

struct AnnotationToolbar: View {
    @Bindable var viewModel: PDFViewModel

    var body: some View {
        HStack(spacing: 12) {
            annotationButton(.highlight, icon: "highlighter", label: "Highlight")
            annotationButton(.note, icon: "note.text", label: "Note")
            annotationButton(.freehand, icon: "pencil.tip", label: "Draw")

            Divider()
                .frame(height: 16)

            ColorPicker("", selection: highlightColorBinding)
                .labelsHidden()
                .frame(width: 24)

            Divider()
                .frame(height: 16)

            Button {
                viewModel.addHighlightAnnotation()
            } label: {
                Image(systemName: "plus.circle")
            }
            .help("Add highlight to selection")
            .disabled(viewModel.annotationMode != .highlight)

            Divider()
                .frame(height: 16)

            Button {
                exportAnnotations()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .help("Export annotations as Markdown")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }

    private func annotationButton(_ mode: PDFViewModel.AnnotationMode, icon: String, label: String) -> some View {
        Button {
            viewModel.toggleAnnotationMode(mode)
        } label: {
            Image(systemName: icon)
                .foregroundStyle(viewModel.annotationMode == mode ? .white : .primary)
                .padding(6)
                .background(viewModel.annotationMode == mode ? Color.accentColor : Color.clear, in: RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.borderless)
        .help(label)
    }

    private var highlightColorBinding: Binding<Color> {
        Binding(
            get: { Color(nsColor: viewModel.highlightColor) },
            set: { viewModel.highlightColor = NSColor($0) }
        )
    }

    private func exportAnnotations() {
        let markdown = viewModel.exportAnnotationsAsMarkdown()
        guard !markdown.isEmpty else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "annotations.md"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? markdown.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
