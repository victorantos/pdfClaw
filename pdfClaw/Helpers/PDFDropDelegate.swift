import SwiftUI
import UniformTypeIdentifiers

struct PDFDropDelegate: DropDelegate {
    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.pdf])
    }

    func performDrop(info: DropInfo) -> Bool {
        // DocumentGroup handles the actual file opening
        // This delegate provides validation for drag & drop UI feedback
        return false
    }
}
