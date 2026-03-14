# Contributing to pdfClaw

Thanks for your interest in contributing! pdfClaw is a small, focused project — contributions that keep it fast and simple are welcome.

## Getting Started

### Requirements

- macOS 14+ (Sonoma or later)
- Xcode 15+
- That's it. Zero external dependencies.

### Build & Run

```bash
git clone https://github.com/victorantos/pdfClaw.git
cd pdfClaw
open pdfClaw.xcodeproj
```

Hit Cmd+R in Xcode to build and run.

Or from the command line:

```bash
xcodebuild -scheme pdfClaw -configuration Debug build
```

### Project Structure

| Directory | Purpose |
|---|---|
| `App/` | App entry point (`@main`), menu commands |
| `Models/` | `PDFFileDocument` (FileDocument), `AppSettings` |
| `Views/` | SwiftUI views and `NSViewRepresentable` wrappers for PDFKit |
| `ViewModels/` | `PDFViewModel` — central state management |
| `Helpers/` | Utilities (drag & drop) |
| `Resources/` | Asset catalog, Info.plist, entitlements |
| `scripts/` | Icon generation and build scripts |

### Architecture

- **MVVM** — Views observe `PDFViewModel` (@Observable)
- **PDFKit** — Apple's built-in framework does the heavy lifting. `PDFKitView` wraps `PDFView` via `NSViewRepresentable`
- **DocumentGroup** — SwiftUI's document-based app pattern handles file opening, recent files, and multi-window

## How to Contribute

### Found a bug?

Open an issue with:
- What you expected
- What happened
- macOS version and PDF file (if possible)

### Want to add a feature?

1. Check [Issues](https://github.com/victorantos/pdfClaw/issues) — it might already be planned
2. Open an issue to discuss before writing code
3. Keep it small and focused — one feature per PR

### Submitting a PR

1. Fork the repo
2. Create a branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test with various PDFs (small, large, encrypted, with/without TOC)
5. Open a PR with a clear description

### Code Style

- Follow existing patterns in the codebase
- No external dependencies — everything from Apple frameworks
- Keep the app under 5 MB
- Every action should have a keyboard shortcut

## What We're Looking For

Check issues labeled [`good first issue`](https://github.com/victorantos/pdfClaw/labels/good%20first%20issue) and [`help wanted`](https://github.com/victorantos/pdfClaw/labels/help%20wanted).

## License

By contributing, you agree that your contributions will be licensed under GPL v3.
