# pdfClaw

**A lightweight, native macOS PDF viewer. 2 MB instead of 2,350 MB.**

pdfClaw is a fast, distraction-free PDF viewer built entirely with Swift, SwiftUI, and Apple's PDFKit. Zero external dependencies. Zero bloat. Zero telemetry.

<!-- TODO: Add screenshot/GIF here -->
<!-- ![pdfClaw screenshot](assets/screenshot.png) -->

## Why?

Adobe Acrobat Reader requires **2.35 GB** to install just to open a PDF. macOS Preview works but is limited. pdfClaw gives you everything you need in under **2 MB**.

| | pdfClaw | Adobe Acrobat | Preview |
|---|---|---|---|
| **Size** | ~2 MB | 2,350 MB | Built-in |
| **Launch time** | Instant | 3-5 seconds | Fast |
| **Telemetry** | None | Yes | Minimal |
| **Account required** | No | Yes | No |
| **Open source** | Yes (GPL v3) | No | No |
| **Keyboard-first** | Yes | Limited | Limited |

## Features

- Native macOS app — window tiling, full screen, tabs, Spotlight all work
- Continuous scroll with smooth rendering
- Thumbnail sidebar + Table of Contents
- Find in document (Cmd+F) with incremental search
- Full keyboard navigation + Vim-style keys (j/k, gg/G, d/u)
- Reading mode — distraction-free overlay with themes (standard, sepia, dark) and margin auto-crop
- Annotations — highlights, notes, freehand drawing, and markdown export
- Split view — compare two PDFs side-by-side
- Lazy page loading, adaptive rendering, and page prefetching for speed
- Encrypted PDF support (password prompt)
- Print support
- Dark mode
- Remembers last position per file
- Drag & drop

## Keyboard Shortcuts

| Action | Shortcut |
|---|---|
| Open file | Cmd+O |
| Find | Cmd+F |
| Next/Prev match | Cmd+G / Shift+Cmd+G |
| Go to page | Cmd+Option+G |
| Zoom in/out | Cmd+= / Cmd+- |
| Fit to width | Cmd+0 |
| Actual size | Cmd+1 |
| Next/Prev page | Cmd+Down / Cmd+Up |
| Toggle sidebar | Shift+Cmd+S |
| Reading mode | Shift+Cmd+R |
| Scroll down/up (vim) | j / k |
| Half-page down/up | d / u |
| Top/Bottom of document | gg / G |
| Print | Cmd+P |

## Install

### Homebrew (coming soon)

```bash
brew install --cask pdfclaw
```

### Manual

1. Download the latest `.zip` from [Releases](https://github.com/victorantos/pdfClaw/releases)
2. Unzip and move `pdfClaw.app` to Applications
3. Double-click to open — macOS will block it since the app isn't notarized yet. Click **OK** to dismiss the dialog.
4. Go to **System Settings → Privacy & Security**, scroll down to Security, and click **Open Anyway** next to _"pdfClaw" was blocked to protect your Mac_.
5. pdfClaw will launch — macOS remembers your choice so you only need to do this once.

### Build from Source

Requires Xcode 15+ and macOS 14+.

```bash
git clone https://github.com/victorantos/pdfClaw.git
cd pdfClaw
xcodebuild -scheme pdfClaw -configuration Release build
```

Or open `pdfClaw.xcodeproj` in Xcode and hit Run.

## Project Structure

```
pdfClaw/
  App/           — App entry point, menu commands
  Models/        — FileDocument, settings
  Views/         — SwiftUI views + NSViewRepresentable wrappers
  ViewModels/    — PDFViewModel (central state management)
  Helpers/       — Drag & drop
  Resources/     — Assets, Info.plist, entitlements
```

## Roadmap

- [x] Vim-style navigation (j/k, gg/G, d/u)
- [x] Reading mode with margin cropping
- [x] Annotations (highlights, notes, freehand)
- [x] Split view — compare two PDFs side-by-side
- [ ] Presentation mode
- [ ] Homebrew cask
- [ ] Notarized .dmg releases

See [Issues](https://github.com/victorantos/pdfClaw/issues) for the full list.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get started.

## License

GPL v3 — see [LICENSE](LICENSE).

Copyright (C) 2026 [Victor Antofica](https://victorantos.com)
