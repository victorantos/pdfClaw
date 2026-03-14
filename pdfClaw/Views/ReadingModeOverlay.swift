import SwiftUI

struct ReadingModeOverlay: View {
    let theme: PDFViewModel.ReadingTheme

    var body: some View {
        switch theme {
        case .standard:
            Color.clear
        case .sepia:
            Color(red: 0.94, green: 0.87, blue: 0.73)
                .blendMode(.multiply)
                .opacity(0.4)
                .allowsHitTesting(false)
        case .dark:
            Color.white
                .blendMode(.difference)
                .allowsHitTesting(false)
        }
    }
}
