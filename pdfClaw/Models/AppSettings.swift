import SwiftUI
import PDFKit

final class AppSettings: ObservableObject {
    @AppStorage("defaultDisplayMode") var defaultDisplayMode: Int = PDFDisplayMode.singlePageContinuous.rawValue
    @AppStorage("showSidebarOnOpen") var showSidebarOnOpen: Bool = false
    @AppStorage("restoreLastPosition") var restoreLastPosition: Bool = true
}
