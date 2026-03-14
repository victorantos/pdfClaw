import SwiftUI
import PDFKit

struct ContentView: View {
    let document: PDFFileDocument
    @State private var viewModel = PDFViewModel()

    var body: some View {
        NavigationSplitView(columnVisibility: sidebarVisibility) {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 300)
        } detail: {
            pdfContent
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                ToolbarView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadDocument(from: document.data)
        }
        .sheet(isPresented: $viewModel.showPasswordPrompt) {
            PasswordPromptView(viewModel: viewModel)
        }
        .popover(isPresented: $viewModel.showGoToPage) {
            GoToPageView(viewModel: viewModel)
        }
        .focusedSceneValue(\.pdfViewModel, viewModel)
    }

    private var sidebarVisibility: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { viewModel.showSidebar ? .all : .detailOnly },
            set: { viewModel.showSidebar = ($0 != .detailOnly) }
        )
    }

    @ViewBuilder
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            Picker("Sidebar", selection: $viewModel.sidebarMode) {
                ForEach(PDFViewModel.SidebarMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(8)

            Divider()

            switch viewModel.sidebarMode {
            case .thumbnails:
                PDFThumbnailSidebarView(pdfView: viewModel.pdfView)
            case .outline:
                OutlineSidebarView(
                    outline: viewModel.pdfDocument?.outlineRoot,
                    viewModel: viewModel
                )
            }
        }
    }

    @ViewBuilder
    private var pdfContent: some View {
        ZStack(alignment: .top) {
            if viewModel.isLoading {
                ProgressView("Loading PDF...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.pdfDocument != nil, !viewModel.isDocumentLocked {
                ZStack {
                    PDFKitView(viewModel: viewModel)
                    KeyboardHandler(viewModel: viewModel)
                }
            } else if !viewModel.isDocumentLocked {
                WelcomeView()
            }

            if viewModel.showSearch {
                SearchBarView(viewModel: viewModel)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.showSearch)
    }
}

// MARK: - Password Prompt

private struct PasswordPromptView: View {
    let viewModel: PDFViewModel
    @State private var password: String = ""
    @State private var showError: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.doc")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("This PDF is encrypted")
                .font(.headline)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
                .onSubmit { tryUnlock() }

            if showError {
                Text("Incorrect password")
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Unlock") { tryUnlock() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
    }

    private func tryUnlock() {
        if viewModel.unlockDocument(password: password) {
            dismiss()
        } else {
            showError = true
            password = ""
        }
    }
}

// MARK: - Focused Value for Menu Commands

struct PDFViewModelKey: FocusedValueKey {
    typealias Value = PDFViewModel
}

extension FocusedValues {
    var pdfViewModel: PDFViewModel? {
        get { self[PDFViewModelKey.self] }
        set { self[PDFViewModelKey.self] = newValue }
    }
}
