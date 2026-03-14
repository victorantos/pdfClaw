import SwiftUI
import PDFKit
import Combine

@Observable
final class PDFViewModel {
    // MARK: - Document State
    var pdfDocument: PDFDocument?
    var currentPageIndex: Int = 0
    var pageCount: Int = 0
    var scaleFactor: CGFloat = 1.0

    // MARK: - UI State
    var showSidebar: Bool = false
    var sidebarMode: SidebarMode = .thumbnails
    var showSearch: Bool = false
    var showGoToPage: Bool = false
    var showPasswordPrompt: Bool = false
    var isDocumentLocked: Bool = false

    // MARK: - Search State
    var searchText: String = ""
    var searchResults: [PDFSelection] = []
    var currentSearchIndex: Int = 0
    var isSearching: Bool = false

    // MARK: - PDFView Reference
    weak var pdfView: PDFView? {
        didSet { configurePDFView() }
    }

    private var searchDebounceTask: Task<Void, Never>?

    enum SidebarMode: String, CaseIterable, Identifiable {
        case thumbnails = "Thumbnails"
        case outline = "Table of Contents"
        var id: String { rawValue }
    }

    var isLoading: Bool = false

    private var prefetchQueue = DispatchQueue(label: "com.pdfclaw.prefetch", qos: .utility)
    private var interpolationResetTask: Task<Void, Never>?

    // MARK: - Document Loading

    func loadDocument(from data: Data) {
        isLoading = true
        let dataCopy = data
        Task.detached(priority: .userInitiated) { [weak self] in
            let doc = PDFDocument(data: dataCopy)
            await MainActor.run {
                guard let self else { return }
                self.isLoading = false
                if let doc {
                    if doc.isLocked {
                        self.isDocumentLocked = true
                        self.showPasswordPrompt = true
                        self.pdfDocument = doc
                    } else {
                        self.pdfDocument = doc
                        self.pageCount = doc.pageCount
                        self.isDocumentLocked = false
                    }
                }
                self.applyDocumentToPDFView()
                self.restoreLastPosition()
            }
        }
    }

    func unlockDocument(password: String) -> Bool {
        guard let doc = pdfDocument, doc.isLocked else { return false }
        if doc.unlock(withPassword: password) {
            isDocumentLocked = false
            showPasswordPrompt = false
            pageCount = doc.pageCount
            applyDocumentToPDFView()
            return true
        }
        return false
    }

    // MARK: - PDFView Configuration

    private func configurePDFView() {
        guard let pdfView else { return }
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .controlBackgroundColor
        pdfView.interpolationQuality = .high
        applyDocumentToPDFView()
    }

    private func applyDocumentToPDFView() {
        guard let pdfView, let pdfDocument else { return }
        if pdfView.document !== pdfDocument {
            pdfView.document = pdfDocument
        }
    }

    // MARK: - Navigation

    func goToPage(_ index: Int) {
        guard let doc = pdfDocument, let pdfView,
              index >= 0, index < doc.pageCount,
              let page = doc.page(at: index) else { return }
        pdfView.go(to: page)
        currentPageIndex = index
    }

    func nextPage() {
        if pdfView?.canGoToNextPage == true {
            pdfView?.goToNextPage(nil)
        }
    }

    func previousPage() {
        if pdfView?.canGoToPreviousPage == true {
            pdfView?.goToPreviousPage(nil)
        }
    }

    func goToFirstPage() {
        if pdfView?.canGoToFirstPage == true {
            pdfView?.goToFirstPage(nil)
        }
    }

    func goToLastPage() {
        if pdfView?.canGoToLastPage == true {
            pdfView?.goToLastPage(nil)
        }
    }

    // MARK: - Zoom

    func zoomIn() {
        pdfView?.zoomIn(nil)
        syncScale()
    }

    func zoomOut() {
        pdfView?.zoomOut(nil)
        syncScale()
    }

    func fitToWidth() {
        guard let pdfView else { return }
        pdfView.autoScales = true
        syncScale()
    }

    func actualSize() {
        guard let pdfView else { return }
        pdfView.scaleFactor = 1.0
        pdfView.autoScales = false
        syncScale()
    }

    func syncScale() {
        scaleFactor = pdfView?.scaleFactor ?? 1.0
    }

    func syncPageIndex() {
        guard let pdfView, let currentPage = pdfView.currentPage,
              let doc = pdfView.document else { return }
        currentPageIndex = doc.index(for: currentPage)
        prefetchAdjacentPages()
    }

    // MARK: - Adaptive Interpolation

    func onScrollBegan() {
        interpolationResetTask?.cancel()
        pdfView?.interpolationQuality = .none
    }

    func onScrollEnded() {
        interpolationResetTask?.cancel()
        interpolationResetTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard !Task.isCancelled else { return }
            self?.pdfView?.interpolationQuality = .high
        }
    }

    // MARK: - Page Prefetching

    private func prefetchAdjacentPages() {
        guard let doc = pdfDocument else { return }
        let index = currentPageIndex
        let pagesToPrefetch = [index - 1, index + 1, index + 2].filter { $0 >= 0 && $0 < doc.pageCount }
        prefetchQueue.async {
            for i in pagesToPrefetch {
                guard let page = doc.page(at: i) else { continue }
                let size = page.bounds(for: .mediaBox).size
                _ = page.thumbnail(of: size, for: .mediaBox)
            }
        }
    }

    // MARK: - Search

    func performSearch() {
        searchDebounceTask?.cancel()
        let query = searchText
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        searchDebounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            startSearch(query: query)
        }
    }

    private func startSearch(query: String) {
        guard let doc = pdfDocument else { return }
        clearSearchResults()
        isSearching = true
        doc.cancelFindString()
        doc.delegate = SearchDelegate.shared
        SearchDelegate.shared.viewModel = self
        doc.beginFindString(query, withOptions: [.caseInsensitive])
    }

    func didFindMatch(_ selection: PDFSelection) {
        searchResults.append(selection)
        if searchResults.count == 1 {
            highlightCurrentResult()
        }
    }

    func didFinishSearch() {
        isSearching = false
    }

    func nextSearchResult() {
        guard !searchResults.isEmpty else { return }
        currentSearchIndex = (currentSearchIndex + 1) % searchResults.count
        highlightCurrentResult()
    }

    func previousSearchResult() {
        guard !searchResults.isEmpty else { return }
        currentSearchIndex = (currentSearchIndex - 1 + searchResults.count) % searchResults.count
        highlightCurrentResult()
    }

    private func highlightCurrentResult() {
        guard !searchResults.isEmpty, let pdfView else { return }
        let selection = searchResults[currentSearchIndex]
        pdfView.currentSelection = selection
        pdfView.go(to: selection)

        // Highlight all matches
        pdfView.highlightedSelections = searchResults
    }

    func clearSearch() {
        clearSearchResults()
        showSearch = false
        searchText = ""
    }

    private func clearSearchResults() {
        pdfDocument?.cancelFindString()
        searchResults = []
        currentSearchIndex = 0
        isSearching = false
        pdfView?.highlightedSelections = nil
        pdfView?.currentSelection = nil
    }

    // MARK: - Position Persistence

    private var documentKey: String? {
        guard let doc = pdfDocument, let url = doc.documentURL else { return nil }
        return "lastPage_\(url.absoluteString.hashValue)"
    }

    func saveCurrentPosition() {
        guard let key = documentKey else { return }
        UserDefaults.standard.set(currentPageIndex, forKey: key)
    }

    private func restoreLastPosition() {
        guard let key = documentKey else { return }
        let savedIndex = UserDefaults.standard.integer(forKey: key)
        if savedIndex > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.goToPage(savedIndex)
            }
        }
    }

    // MARK: - Print

    func printDocument() {
        pdfView?.print(with: .shared, autoRotate: true)
    }

    // MARK: - Toggle Sidebar

    func toggleSidebar() {
        showSidebar.toggle()
    }
}

// MARK: - Search Delegate

final class SearchDelegate: NSObject, PDFDocumentDelegate {
    static let shared = SearchDelegate()
    weak var viewModel: PDFViewModel?

    func didMatchString(_ instance: PDFSelection) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.didFindMatch(instance)
        }
    }

    func documentDidEndDocumentFind(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.didFinishSearch()
        }
    }
}
