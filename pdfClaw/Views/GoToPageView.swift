import SwiftUI

struct GoToPageView: View {
    @Bindable var viewModel: PDFViewModel
    @State private var pageNumberText: String = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Go to Page")
                .font(.headline)

            HStack {
                TextField("Page number", text: $pageNumberText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFieldFocused)
                    .onSubmit { goToPage() }
                    .frame(width: 100)

                Text("of \(viewModel.pageCount)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Cancel") {
                    viewModel.showGoToPage = false
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button("Go") {
                    goToPage()
                }
                .keyboardShortcut(.return, modifiers: [])
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 220)
        .onAppear {
            pageNumberText = "\(viewModel.currentPageIndex + 1)"
            isFieldFocused = true
        }
    }

    private func goToPage() {
        if let page = Int(pageNumberText), page >= 1, page <= viewModel.pageCount {
            viewModel.goToPage(page - 1)
            viewModel.showGoToPage = false
        }
    }
}
