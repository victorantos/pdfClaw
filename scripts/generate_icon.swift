#!/usr/bin/env swift

import AppKit
import CoreGraphics

func generateIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let s = size // shorthand
    let u = s / 512.0 // unit scale

    // MARK: - Background: rounded rectangle
    let bgRect = CGRect(x: s * 0.02, y: s * 0.02, width: s * 0.96, height: s * 0.96)
    let cornerRadius = s * 0.18
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Gradient background - deep charcoal to near-black
    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    let bgColors = [
        CGColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0),
        CGColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    ]
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors as CFArray, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: s/2, y: s), end: CGPoint(x: s/2, y: 0), options: [])
    ctx.restoreGState()

    // MARK: - PDF Page (white document, slightly tilted)
    ctx.saveGState()

    // Center the page
    let pageW = s * 0.42
    let pageH = s * 0.52
    let pageX = s * 0.29
    let pageY = s * 0.18

    // Slight rotation for dynamism
    ctx.translateBy(x: pageX + pageW/2, y: pageY + pageH/2)
    ctx.rotate(by: -0.05)
    ctx.translateBy(x: -(pageX + pageW/2), y: -(pageY + pageH/2))

    // Page shadow
    ctx.setShadow(offset: CGSize(width: 2*u, height: -4*u), blur: 12*u, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))

    // Page body
    let pagePath = CGMutablePath()
    let foldSize = s * 0.08
    pagePath.move(to: CGPoint(x: pageX, y: pageY + pageH))
    pagePath.addLine(to: CGPoint(x: pageX + pageW - foldSize, y: pageY + pageH))
    pagePath.addLine(to: CGPoint(x: pageX + pageW, y: pageY + pageH - foldSize))
    pagePath.addLine(to: CGPoint(x: pageX + pageW, y: pageY))
    pagePath.addLine(to: CGPoint(x: pageX, y: pageY))
    pagePath.closeSubpath()

    ctx.setFillColor(CGColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0))
    ctx.addPath(pagePath)
    ctx.fillPath()

    // Remove shadow for details
    ctx.setShadow(offset: .zero, blur: 0, color: nil)

    // Dog-ear fold
    let foldPath = CGMutablePath()
    foldPath.move(to: CGPoint(x: pageX + pageW - foldSize, y: pageY + pageH))
    foldPath.addLine(to: CGPoint(x: pageX + pageW - foldSize, y: pageY + pageH - foldSize))
    foldPath.addLine(to: CGPoint(x: pageX + pageW, y: pageY + pageH - foldSize))
    foldPath.closeSubpath()

    ctx.setFillColor(CGColor(red: 0.82, green: 0.82, blue: 0.85, alpha: 1.0))
    ctx.addPath(foldPath)
    ctx.fillPath()

    // "PDF" text on the page
    let pdfFontSize = s * 0.09
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: pdfFontSize, weight: .bold),
        .foregroundColor: NSColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 1.0)
    ]
    let pdfStr = NSAttributedString(string: "PDF", attributes: attrs)
    pdfStr.draw(at: NSPoint(x: pageX + pageW * 0.2, y: pageY + pageH * 0.15))

    // Fake text lines on the page
    ctx.setFillColor(CGColor(red: 0.78, green: 0.78, blue: 0.82, alpha: 1.0))
    let lineH = s * 0.018
    let lineGap = s * 0.032
    for i in 0..<4 {
        let lineY = pageY + pageH * 0.45 + CGFloat(i) * lineGap
        let lineW = (i == 3) ? pageW * 0.45 : pageW * 0.7
        let lineRect = CGRect(x: pageX + pageW * 0.12, y: lineY, width: lineW, height: lineH)
        ctx.fill(lineRect)
    }

    ctx.restoreGState()

    // MARK: - Claw Marks (3 diagonal scratches)
    ctx.saveGState()

    // Three claw scratch marks going from upper-right to lower-left across the page
    let clawColor1 = CGColor(red: 0.90, green: 0.25, blue: 0.20, alpha: 1.0)
    let clawColor2 = CGColor(red: 1.00, green: 0.40, blue: 0.25, alpha: 1.0)

    for i in 0..<3 {
        let offset = CGFloat(i) * s * 0.07
        let startX = s * 0.28 + offset
        let startY = s * 0.78
        let endX = s * 0.58 + offset
        let endY = s * 0.22

        let clawPath = CGMutablePath()

        // Slightly curved claw mark
        clawPath.move(to: CGPoint(x: startX, y: startY))
        clawPath.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: startX + s * 0.06, y: startY - s * 0.18),
            control2: CGPoint(x: endX - s * 0.04, y: endY + s * 0.22)
        )

        // Tapered stroke: thicker in middle, thin at ends
        ctx.saveGState()

        // Shadow/glow on claw marks
        ctx.setShadow(offset: .zero, blur: 6*u, color: CGColor(red: 1.0, green: 0.3, blue: 0.15, alpha: 0.6))

        ctx.addPath(clawPath)
        ctx.setStrokeColor(clawColor1)
        ctx.setLineWidth(s * 0.028)
        ctx.setLineCap(.round)
        ctx.strokePath()

        // Inner lighter stroke
        ctx.setShadow(offset: .zero, blur: 0, color: nil)
        ctx.addPath(clawPath)
        ctx.setStrokeColor(clawColor2)
        ctx.setLineWidth(s * 0.012)
        ctx.setLineCap(.round)
        ctx.strokePath()

        ctx.restoreGState()

        // Sharp point at the end (claw tip)
        let tipPath = CGMutablePath()
        tipPath.move(to: CGPoint(x: endX - s*0.012, y: endY + s*0.02))
        tipPath.addLine(to: CGPoint(x: endX, y: endY - s*0.015))
        tipPath.addLine(to: CGPoint(x: endX + s*0.012, y: endY + s*0.02))
        tipPath.closeSubpath()

        ctx.setFillColor(clawColor1)
        ctx.addPath(tipPath)
        ctx.fillPath()
    }

    ctx.restoreGState()

    // MARK: - Subtle border on the rounded rect
    ctx.addPath(bgPath)
    ctx.setStrokeColor(CGColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.5))
    ctx.setLineWidth(1.0 * u)
    ctx.strokePath()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String, pixelSize: Int) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
    NSGraphicsContext.restoreGraphicsState()

    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: path))
}

// Generate all required sizes
let sizes: [(point: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2),
]

let basePath = "pdfClaw/Resources/Assets.xcassets/AppIcon.appiconset"

// Generate at 1024px (highest quality) and scale down
let masterIcon = generateIcon(size: 1024)

for (point, scale) in sizes {
    let pixel = point * scale
    let filename = "icon_\(point)x\(point)@\(scale)x.png"
    let path = "\(basePath)/\(filename)"
    savePNG(masterIcon, to: path, pixelSize: pixel)
    print("Generated \(filename) (\(pixel)x\(pixel)px)")
}

print("Done! All icons generated.")
