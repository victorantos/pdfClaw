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
