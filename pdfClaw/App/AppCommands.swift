import SwiftUI

struct AppCommands: Commands {
    @FocusedValue(\.pdfViewModel) var viewModel

    var body: some Commands {
        // MARK: - View Menu
        CommandGroup(after: .toolbar) {
            Section {
                Button("Zoom In") {
                    viewModel?.zoomIn()
                }
                .keyboardShortcut("=", modifiers: .command)

                Button("Zoom Out") {
                    viewModel?.zoomOut()
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Fit to Width") {
                    viewModel?.fitToWidth()
                }
                .keyboardShortcut("0", modifiers: .command)

                Button("Actual Size") {
                    viewModel?.actualSize()
                }
                .keyboardShortcut("1", modifiers: .command)
            }

            Section {
                Button("Toggle Sidebar") {
                    viewModel?.toggleSidebar()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }

            Section {
                Button("Toggle Split View") {
                    viewModel?.isSplitViewActive.toggle()
                }
                .keyboardShortcut("v", modifiers: [.command, .shift])
            }

            Section {
                Button("Toggle Reading Mode") {
                    viewModel?.toggleReadingMode()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Cycle Theme") {
                    viewModel?.cycleTheme()
                }
                .keyboardShortcut("t", modifiers: .command)

                Button("Toggle Auto-Crop Margins") {
                    viewModel?.toggleAutoCrop()
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
        }

        // MARK: - Annotations
        CommandMenu("Annotate") {
            Button("Highlight Mode") {
                viewModel?.toggleAnnotationMode(.highlight)
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Button("Note Mode") {
                viewModel?.toggleAnnotationMode(.note)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Button("Freehand Mode") {
                viewModel?.toggleAnnotationMode(.freehand)
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])

            Divider()

            Button("Add Highlight to Selection") {
                viewModel?.addHighlightAnnotation()
            }
            .keyboardShortcut("h", modifiers: [.command, .option])

            Divider()

            Button("Export Annotations…") {
                guard let vm = viewModel else { return }
                let markdown = vm.exportAnnotationsAsMarkdown()
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
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }

        // MARK: - Go Menu
        CommandMenu("Go") {
            Button("Next Page") {
                viewModel?.nextPage()
            }
            .keyboardShortcut(.downArrow, modifiers: .command)

            Button("Previous Page") {
                viewModel?.previousPage()
            }
            .keyboardShortcut(.upArrow, modifiers: .command)

            Divider()

            Button("First Page") {
                viewModel?.goToFirstPage()
            }
            .keyboardShortcut(.home, modifiers: [])

            Button("Last Page") {
                viewModel?.goToLastPage()
            }
            .keyboardShortcut(.end, modifiers: [])

            Divider()

            Button("Go to Page…") {
                viewModel?.showGoToPage = true
            }
            .keyboardShortcut("g", modifiers: [.command, .option])
        }

        // MARK: - Find
        CommandGroup(after: .textEditing) {
            Section {
                Button("Find…") {
                    viewModel?.showSearch = true
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }

        // MARK: - Print
        CommandGroup(replacing: .printItem) {
            Button("Print…") {
                viewModel?.printDocument()
            }
            .keyboardShortcut("p", modifiers: .command)
        }
    }
}
