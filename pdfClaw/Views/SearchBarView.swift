import SwiftUI

struct SearchBarView: View {
    @Bindable var viewModel: PDFViewModel
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    viewModel.nextSearchResult()
                }
                .onChange(of: viewModel.searchText) {
                    viewModel.performSearch()
                }

            if !viewModel.searchResults.isEmpty {
                Text("\(viewModel.currentSearchIndex + 1) of \(viewModel.searchResults.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            } else if viewModel.isSearching {
                ProgressView()
                    .controlSize(.small)
            }

            Button {
                viewModel.previousSearchResult()
            } label: {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.searchResults.isEmpty)
            .keyboardShortcut("g", modifiers: [.command, .shift])

            Button {
                viewModel.nextSearchResult()
            } label: {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.searchResults.isEmpty)
            .keyboardShortcut("g", modifiers: .command)

            Button {
                viewModel.clearSearch()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .padding(.horizontal, 16)
        .onAppear {
            isSearchFieldFocused = true
        }
    }
}
