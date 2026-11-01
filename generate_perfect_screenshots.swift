import AppKit
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Canvas Dimensions matching standard Apple App Store / Marketing Retina aspect ratio
let canvasWidth: CGFloat = 1286
let canvasHeight: CGFloat = 804

func createRetinaCanvas() -> (NSImage, CGContext) {
    let image = NSImage(size: NSSize(width: canvasWidth, height: canvasHeight))
    image.lockFocusFlipped(true)
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        fatalError("Failed to acquire CGContext")
    }
    // High-quality rendering settings
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high
    
    // Fill clean white background
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fill(CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
    
    return (image, ctx)
}

func savePNG(image: NSImage, path: String) {
    image.unlockFocus()
    guard let tiffData = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiffData),
          let pngData = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to convert image to PNG for path: \(path)")
    }
    let url = URL(fileURLWithPath: path)
    try! pngData.write(to: url)
    print("Saved \(path) (\(pngData.count) bytes)")
}

// MARK: - Drawing Components

// Exact Menu Bar Icon matching MenuBarIconGenerator.swift
func drawExactMenuBarIcon(ctx: CGContext, center: CGPoint, scale: CGFloat = 1.0, isDark: Bool = false, active: Bool = true) {
    ctx.saveGState()
    
    // Center & scale
    ctx.translateBy(x: center.x, y: center.y)
    ctx.scaleBy(x: scale, y: scale)
    
    let tint = isDark ? NSColor.white : NSColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0)
    ctx.setFillColor(tint.cgColor)
    ctx.setStrokeColor(tint.cgColor)
    
    // Saucer: at bottom (y = 5.0 to 6.8 in flipped coordinates)
    let saucerRect = CGRect(x: -7.5, y: 5.0, width: 13.5, height: 1.8)
    let saucerPath = CGPath(roundedRect: saucerRect, cornerWidth: 0.9, cornerHeight: 0.9, transform: nil)
    ctx.addPath(saucerPath)
    ctx.fillPath()
    
    // Cup: sitting on saucer (y = -3.0 to 4.8)
    let cupRect = CGRect(x: -6.0, y: -3.0, width: 10.5, height: 7.8)
    let cupPath = CGPath(roundedRect: cupRect, cornerWidth: 2.2, cornerHeight: 2.2, transform: nil)
    ctx.addPath(cupPath)
    if active {
        ctx.fillPath()
    } else {
        ctx.setLineWidth(1.3)
        ctx.strokePath()
    }
    
    // Handle on the right
    let handleRect = CGRect(x: cupRect.maxX - 0.8, y: -1.2, width: 3.4, height: 4.4)
    let handlePath = CGPath(roundedRect: handleRect, cornerWidth: 1.7, cornerHeight: 1.7, transform: nil)
    ctx.setLineWidth(1.3)
    ctx.addPath(handlePath)
    ctx.strokePath()
    
    // Rising Steam (2 curved lines above cup: y = -4.5 to -8.8)
    if active {
        ctx.setLineWidth(1.2)
        ctx.setLineCap(.round)
        
        // Left steam wisp
        let s1 = CGMutablePath()
        s1.move(to: CGPoint(x: -2.8, y: -4.5))
        s1.addCurve(to: CGPoint(x: -2.8, y: -8.8),
                    control1: CGPoint(x: -4.0, y: -6.0),
                    control2: CGPoint(x: -1.6, y: -7.4))
        ctx.addPath(s1)
        ctx.strokePath()
        
        // Right steam wisp
        let s2 = CGMutablePath()
        s2.move(to: CGPoint(x: 1.6, y: -4.5))
        s2.addCurve(to: CGPoint(x: 1.6, y: -8.8),
                    control1: CGPoint(x: 0.4, y: -6.0),
                    control2: CGPoint(x: 2.8, y: -7.4))
        ctx.addPath(s2)
        ctx.strokePath()
    }
    
    ctx.restoreGState()
}

func drawBezelAndScreen(ctx: CGContext, screenRect: CGRect, isDark: Bool = false, drawSplit: Bool = false) {
    ctx.saveGState()
    
    // Outer Laptop Display Frame (Dark Anodized Aluminum)
    let outerRect = screenRect.insetBy(dx: -18, dy: -18).offsetBy(dx: 0, dy: -4)
    let outerPath = CGPath(roundedRect: outerRect, cornerWidth: 32, cornerHeight: 32, transform: nil)
    
    // Display frame shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 16), blur: 36, color: NSColor(white: 0, alpha: 0.18).cgColor)
    ctx.setFillColor(NSColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0).cgColor)
    ctx.addPath(outerPath)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Inner Display Border / Bezel
    let bezelPath = CGPath(roundedRect: screenRect.insetBy(dx: -3, dy: -3), cornerWidth: 20, cornerHeight: 20, transform: nil)
    ctx.setFillColor(NSColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1.0).cgColor)
    ctx.addPath(bezelPath)
    ctx.fillPath()
    
    // Clip to Screen Viewport
    let screenClip = CGPath(roundedRect: screenRect, cornerWidth: 16, cornerHeight: 16, transform: nil)
    ctx.addPath(screenClip)
    ctx.clip()
    
    // Wallpaper Drawing
    if drawSplit {
        // Split wallpaper (left half light daylight, right half dark deep navy)
        let splitX = screenRect.origin.x + screenRect.width * 0.42
        
        // Light half
        ctx.saveGState()
        ctx.clip(to: CGRect(x: screenRect.origin.x, y: screenRect.origin.y, width: splitX - screenRect.origin.x, height: screenRect.height))
        drawLightWallpaper(ctx: ctx, rect: screenRect)
        ctx.restoreGState()
        
        // Dark half
        ctx.saveGState()
        ctx.clip(to: CGRect(x: splitX, y: screenRect.origin.y, width: screenRect.maxX - splitX, height: screenRect.height))
        drawDarkWallpaper(ctx: ctx, rect: screenRect)
        ctx.restoreGState()
        
        // Split line
        ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.4).cgColor)
        ctx.setLineWidth(2.0)
        ctx.move(to: CGPoint(x: splitX, y: screenRect.origin.y))
        ctx.addLine(to: CGPoint(x: splitX, y: screenRect.maxY))
        ctx.strokePath()
    } else if isDark {
        drawDarkWallpaper(ctx: ctx, rect: screenRect)
    } else {
        drawLightWallpaper(ctx: ctx, rect: screenRect)
    }
    
    // Top macOS Menu Bar
    let menuBarHeight: CGFloat = 36
    let menuBarRect = CGRect(x: screenRect.origin.x, y: screenRect.origin.y, width: screenRect.width, height: menuBarHeight)
    
    ctx.saveGState()
    let menuBarColor = isDark
        ? NSColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 0.75).cgColor
        : NSColor(white: 1.0, alpha: 0.28).cgColor
    ctx.setFillColor(menuBarColor)
    ctx.fill(menuBarRect)
    
    // Bottom border of menu bar
    ctx.setStrokeColor(NSColor(white: isDark ? 0.3 : 1.0, alpha: 0.2).cgColor)
    ctx.setLineWidth(0.5)
    ctx.move(to: CGPoint(x: menuBarRect.minX, y: menuBarRect.maxY))
    ctx.addLine(to: CGPoint(x: menuBarRect.maxX, y: menuBarRect.maxY))
    ctx.strokePath()
    
    ctx.restoreGState()
    ctx.restoreGState()
}

func drawLightWallpaper(ctx: CGContext, rect: CGRect) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(red: 0.15, green: 0.52, blue: 0.92, alpha: 1.0).cgColor,
        NSColor(red: 0.00, green: 0.68, blue: 0.95, alpha: 1.0).cgColor,
        NSColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0).cgColor
    ] as CFArray
    let grad = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    
    // Flowing wave overlay
    ctx.saveGState()
    let wave = CGMutablePath()
    wave.move(to: CGPoint(x: rect.minX, y: rect.minY + 120))
    wave.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 320),
                  control1: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + 40),
                  control2: CGPoint(x: rect.minX + rect.width * 0.70, y: rect.minY + 450))
    wave.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    wave.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    wave.closeSubpath()
    ctx.addPath(wave)
    ctx.clip()
    
    let wColors = [
        NSColor(red: 0.00, green: 0.35, blue: 0.85, alpha: 0.90).cgColor,
        NSColor(red: 0.00, green: 0.65, blue: 0.98, alpha: 0.70).cgColor
    ] as CFArray
    let wGrad = CGGradient(colorsSpace: colorSpace, colors: wColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(wGrad, start: CGPoint(x: rect.minX, y: rect.minY + 100), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    ctx.restoreGState()
}

func drawDarkWallpaper(ctx: CGContext, rect: CGRect) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(red: 0.04, green: 0.06, blue: 0.16, alpha: 1.0).cgColor,
        NSColor(red: 0.06, green: 0.12, blue: 0.28, alpha: 1.0).cgColor,
        NSColor(red: 0.08, green: 0.20, blue: 0.45, alpha: 1.0).cgColor
    ] as CFArray
    let grad = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.5, 1.0])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    
    // Dark fluid curves
    ctx.saveGState()
    let wave = CGMutablePath()
    wave.move(to: CGPoint(x: rect.minX, y: rect.minY + 150))
    wave.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 420),
                  control1: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.minY + 80),
                  control2: CGPoint(x: rect.minX + rect.width * 0.75, y: rect.minY + 520))
    wave.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    wave.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    wave.closeSubpath()
    ctx.addPath(wave)
    ctx.clip()
    
    let wColors = [
        NSColor(red: 0.08, green: 0.16, blue: 0.40, alpha: 0.90).cgColor,
        NSColor(red: 0.02, green: 0.08, blue: 0.25, alpha: 0.95).cgColor
    ] as CFArray
    let wGrad = CGGradient(colorsSpace: colorSpace, colors: wColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(wGrad, start: CGPoint(x: rect.minX, y: rect.minY + 150), end: CGPoint(x: rect.maxX, y: rect.maxY), options: [])
    ctx.restoreGState()
}

// MARK: - Menu Bar Status Icons

func drawCoffeeCup(ctx: CGContext, center: CGPoint, size: CGFloat = 18, isDark: Bool = false, active: Bool = true) {
    drawExactMenuBarIcon(ctx: ctx, center: center, scale: size / 16.0, isDark: isDark, active: active)
}

func drawSystemIcons(ctx: CGContext, startX: CGFloat, y: CGFloat, isDark: Bool = false) {
    let tint = isDark ? NSColor.white : NSColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0)
    ctx.setStrokeColor(tint.cgColor)
    ctx.setFillColor(tint.cgColor)
    ctx.setLineWidth(1.6)
    ctx.setLineCap(.round)
    
    // Wi-Fi Icon
    var cx = startX
    let cy = y
    for r: CGFloat in [4, 8, 12] {
        let arc = CGMutablePath()
        arc.addArc(center: CGPoint(x: cx, y: cy + 4), radius: r, startAngle: -.pi * 0.75, endAngle: -.pi * 0.25, clockwise: false)
        ctx.addPath(arc)
        ctx.strokePath()
    }
    ctx.fillEllipse(in: CGRect(x: cx - 1.5, y: cy + 2.5, width: 3, height: 3))
    
    // Search / Spotlight Icon
    cx += 28
    let sRadius: CGFloat = 4.5
    ctx.strokeEllipse(in: CGRect(x: cx - sRadius, y: cy - sRadius - 1, width: sRadius * 2, height: sRadius * 2))
    ctx.move(to: CGPoint(x: cx + 3.2, y: cy + 2.2))
    ctx.addLine(to: CGPoint(x: cx + 7.5, y: cy + 6.5))
    ctx.strokePath()
    
    // Control Center Icon (two pill sliders)
    cx += 28
    let p1 = CGPath(roundedRect: CGRect(x: cx - 7, y: cy - 5, width: 14, height: 5), cornerWidth: 2.5, cornerHeight: 2.5, transform: nil)
    ctx.addPath(p1)
    ctx.strokePath()
    ctx.fillEllipse(in: CGRect(x: cx - 5, y: cy - 4.5, width: 4, height: 4))
    
    let p2 = CGPath(roundedRect: CGRect(x: cx - 7, y: cy + 1, width: 14, height: 5), cornerWidth: 2.5, cornerHeight: 2.5, transform: nil)
    ctx.addPath(p2)
    ctx.strokePath()
    ctx.fillEllipse(in: CGRect(x: cx + 1, y: cy + 1.5, width: 4, height: 4))
    
    // Time / Date
    cx += 24
    let timeAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 13, weight: .medium),
        .foregroundColor: tint
    ]
    ("Tue Oct 18  9:41 AM" as NSString).draw(at: CGPoint(x: cx, y: cy - 8), withAttributes: timeAttrs)
}

// MARK: - Native Popover Renderer

func drawPopover(ctx: CGContext,
                 rect: CGRect,
                 isDark: Bool = false,
                 activeDurationMinutes: Int = 0,
                 isExpandedSettings: Bool = false) {
    ctx.saveGState()
    
    // macOS Popover Drop Shadow
    ctx.setShadow(offset: CGSize(width: 0, height: 12), blur: 28, color: NSColor(white: 0, alpha: isDark ? 0.45 : 0.22).cgColor)
    
    let popoverPath = CGPath(roundedRect: rect, cornerWidth: 14, cornerHeight: 14, transform: nil)
    ctx.addPath(popoverPath)
    
    // Popover Material Blur Background
    let bgColor = isDark
        ? NSColor(red: 0.11, green: 0.12, blue: 0.16, alpha: 0.96)
        : NSColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 0.95)
    ctx.setFillColor(bgColor.cgColor)
    ctx.fillPath()
    
    // Border stroke
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.setStrokeColor(NSColor(white: isDark ? 0.35 : 0.0, alpha: isDark ? 0.35 : 0.08).cgColor)
    ctx.setLineWidth(1.0)
    ctx.addPath(popoverPath)
    ctx.strokePath()
    
    let textColor = isDark ? NSColor.white : NSColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1.0)
    let secondaryColor = isDark ? NSColor(white: 0.65, alpha: 1.0) : NSColor(white: 0.45, alpha: 1.0)
    let accentCyan = NSColor(red: 0.00, green: 0.68, blue: 0.95, alpha: 1.0)
    
    var currentY = rect.origin.y + 16
    let leftMargin = rect.origin.x + 16
    let rightMargin = rect.maxX - 16
    
    // 1. Header: "Cafaine" + Subtitle + Toggle Switch
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 15, weight: .bold),
        .foregroundColor: textColor
    ]
    ("Cafaine" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY), withAttributes: titleAttrs)
    
    if activeDurationMinutes > 0 {
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: accentCyan
        ]
        ("Active Until 8:45 AM" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY + 18), withAttributes: subAttrs)
    }
    
    // Toggle switch (ON: Blue pill + white circular thumb)
    let switchWidth: CGFloat = 38
    let switchHeight: CGFloat = 22
    let switchRect = CGRect(x: rightMargin - switchWidth, y: currentY + 1, width: switchWidth, height: switchHeight)
    let switchPath = CGPath(roundedRect: switchRect, cornerWidth: switchHeight / 2, cornerHeight: switchHeight / 2, transform: nil)
    ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0).cgColor)
    ctx.addPath(switchPath)
    ctx.fillPath()
    
    // Switch knob
    let knobRect = CGRect(x: switchRect.maxX - switchHeight + 1.5, y: switchRect.minY + 2, width: switchHeight - 4, height: switchHeight - 4)
    ctx.setShadow(offset: CGSize(width: 0, height: 2), blur: 3, color: NSColor(white: 0, alpha: 0.25).cgColor)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fillEllipse(in: knobRect)
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    
    currentY += (activeDurationMinutes > 0 ? 40 : 32)
    
    // Separator line
    ctx.setStrokeColor(NSColor(white: isDark ? 0.3 : 0.0, alpha: isDark ? 0.25 : 0.08).cgColor)
    ctx.setLineWidth(0.5)
    ctx.move(to: CGPoint(x: leftMargin - 4, y: currentY))
    ctx.addLine(to: CGPoint(x: rightMargin + 4, y: currentY))
    ctx.strokePath()
    
    currentY += 10
    
    // 2. Duration Section Header
    let sectionAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12, weight: .medium),
        .foregroundColor: textColor
    ]
    ("Duration" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY), withAttributes: sectionAttrs)
    
    let chevronAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 10, weight: .bold),
        .foregroundColor: secondaryColor
    ]
    (isExpandedSettings ? ">" : "v" as NSString).draw(at: CGPoint(x: rightMargin - 10, y: currentY + 1), withAttributes: chevronAttrs)
    
    currentY += 24
    
    // 3. Duration Row: Exactly ONE Horizontal Row of 8 items matching Caffeinated!
    let pillItems: [(Int, String)] = [
        (0, "∞"),
        (15, "15"),
        (30, "30"),
        (45, "45"),
        (60, "01"),
        (240, "04"),
        (480, "08"),
        (-1, "⚙")
    ]
    
    let pillW: CGFloat = 26
    let pillH: CGFloat = 26
    let pillSpacing: CGFloat = (rightMargin - leftMargin - CGFloat(pillItems.count) * pillW) / CGFloat(pillItems.count - 1)
    
    var px = leftMargin
    for item in pillItems {
        let isSelected = (item.0 == activeDurationMinutes)
        let pRect = CGRect(x: px, y: currentY, width: pillW, height: pillH)
        let pPath = CGPath(roundedRect: pRect, cornerWidth: 6, cornerHeight: 6, transform: nil)
        
        if isSelected {
            ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0).cgColor)
            ctx.addPath(pPath)
            ctx.fillPath()
        } else {
            let bgFill = isDark ? NSColor(white: 1.0, alpha: 0.08) : NSColor(white: 0.0, alpha: 0.05)
            ctx.setFillColor(bgFill.cgColor)
            ctx.addPath(pPath)
            ctx.fillPath()
        }
        
        let pFont = NSFont.systemFont(ofSize: 11, weight: isSelected ? .bold : .medium)
        let pColor = isSelected ? NSColor.white : textColor
        let pAttrs: [NSAttributedString.Key: Any] = [
            .font: pFont,
            .foregroundColor: pColor
        ]
        let pStr = item.1 as NSString
        let pSize = pStr.size(withAttributes: pAttrs)
        pStr.draw(at: CGPoint(x: pRect.midX - pSize.width / 2, y: pRect.midY - pSize.height / 2), withAttributes: pAttrs)
        
        px += pillW + pillSpacing
    }
    
    currentY += pillH + 14
    
    // Separator line
    ctx.move(to: CGPoint(x: leftMargin - 4, y: currentY))
    ctx.addLine(to: CGPoint(x: rightMargin + 4, y: currentY))
    ctx.strokePath()
    
    currentY += 10
    
    // 4. Settings Section (Collapsible Accordion)
    ("Settings" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY), withAttributes: sectionAttrs)
    (isExpandedSettings ? "v" : ">" as NSString).draw(at: CGPoint(x: rightMargin - 10, y: currentY + 1), withAttributes: chevronAttrs)
    
    currentY += 24
    
    if isExpandedSettings {
        // Expanded Setting Items with Blue Circle Glyphs!
        let settings: [(String, Any)] = [
            ("Launch at Login", true),
            ("Activate at Launch", true),
            ("Activate with Left Click", true),
            ("Keyboard Shortcut", "⌥C"),
            ("Allow Display Sleep", false),
            ("Keep Awake with Lid Closed", true),
            ("Allow Notifications", true),
            ("Colored Menu Bar Icon", false),
            ("Activate on Power Connect", false),
            ("Deactivate on Power Disconnect", false)
        ]
        
        for s in settings {
            let rowY = currentY
            
            // Blue circular glyph icon
            let circleRect = CGRect(x: leftMargin, y: rowY + 2, width: 18, height: 18)
            ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: isDark ? 0.25 : 0.15).cgColor)
            ctx.fillEllipse(in: circleRect)
            
            // Inner icon dot/glyph
            ctx.setFillColor(NSColor(red: 0.00, green: 0.55, blue: 1.0, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: circleRect.insetBy(dx: 5, dy: 5))
            
            // Setting Title
            let sAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: textColor
            ]
            (s.0 as NSString).draw(at: CGPoint(x: leftMargin + 26, y: rowY + 4), withAttributes: sAttrs)
            
            // Value: Toggle or Shortcut Pill
            if let shortcut = s.1 as? String {
                let badgeAttrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .bold),
                    .foregroundColor: textColor
                ]
                let bStr = shortcut as NSString
                let bSize = bStr.size(withAttributes: badgeAttrs)
                let bRect = CGRect(x: rightMargin - bSize.width - 10, y: rowY + 3, width: bSize.width + 10, height: 16)
                let bPath = CGPath(roundedRect: bRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
                ctx.setFillColor(NSColor(white: isDark ? 1.0 : 0.0, alpha: isDark ? 0.12 : 0.08).cgColor)
                ctx.addPath(bPath)
                ctx.fillPath()
                bStr.draw(at: CGPoint(x: bRect.midX - bSize.width / 2, y: bRect.midY - bSize.height / 2), withAttributes: badgeAttrs)
            } else if let isOn = s.1 as? Bool {
                let sw: CGFloat = 28
                let sh: CGFloat = 16
                let sRect = CGRect(x: rightMargin - sw, y: rowY + 3, width: sw, height: sh)
                let sPath = CGPath(roundedRect: sRect, cornerWidth: sh / 2, cornerHeight: sh / 2, transform: nil)
                
                if isOn {
                    ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0).cgColor)
                    ctx.addPath(sPath)
                    ctx.fillPath()
                    ctx.setFillColor(NSColor.white.cgColor)
                    ctx.fillEllipse(in: CGRect(x: sRect.maxX - sh + 1, y: sRect.minY + 1.5, width: sh - 3, height: sh - 3))
                } else {
                    ctx.setFillColor(NSColor(white: isDark ? 1.0 : 0.0, alpha: isDark ? 0.15 : 0.12).cgColor)
                    ctx.addPath(sPath)
                    ctx.fillPath()
                    ctx.setFillColor(NSColor.white.cgColor)
                    ctx.fillEllipse(in: CGRect(x: sRect.minX + 2, y: sRect.minY + 1.5, width: sh - 3, height: sh - 3))
                }
            }
            
            currentY += 23
        }
        
        currentY += 6
        // Separator line
        ctx.move(to: CGPoint(x: leftMargin - 4, y: currentY))
        ctx.addLine(to: CGPoint(x: rightMargin + 4, y: currentY))
        ctx.strokePath()
        currentY += 10
    }
    
    // 5. Footer Links: About & Quit
    let footerAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12, weight: .regular),
        .foregroundColor: textColor
    ]
    ("About" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY), withAttributes: footerAttrs)
    currentY += 20
    ("Quit" as NSString).draw(at: CGPoint(x: leftMargin, y: currentY), withAttributes: footerAttrs)
    
    ctx.restoreGState()
}

// MARK: - Slide Renderers

func generateScreenshot1() {
    let (image, ctx) = createRetinaCanvas()
    
    // Left: MacBook Screen Bezel & Popover
    let screenRect = CGRect(x: -80, y: 70, width: 620, height: 750)
    drawBezelAndScreen(ctx: ctx, screenRect: screenRect, isDark: false)
    
    // Coffee cup in menu bar
    let cupCenter = CGPoint(x: 105, y: 88)
    drawCoffeeCup(ctx: ctx, center: cupCenter, size: 20, isDark: false, active: true)
    
    // Status icons
    drawSystemIcons(ctx: ctx, startX: 145, y: 88, isDark: false)
    
    // Popover hanging directly under coffee cup
    let popRect = CGRect(x: 45, y: 125, width: 285, height: 235)
    drawPopover(ctx: ctx, rect: popRect, isDark: false, activeDurationMinutes: 0)
    
    // Right Side: Marketing Typography
    let rightX: CGFloat = 630
    
    // Kicker (Gold-to-Blue Gradient)
    let kicker = "A Simple Anti-Sleep Tool" as NSString
    let kickerFont = NSFont.systemFont(ofSize: 22, weight: .bold)
    let kickerAttrs: [NSAttributedString.Key: Any] = [
        .font: kickerFont,
        .foregroundColor: NSColor(red: 0.85, green: 0.55, blue: 0.05, alpha: 1.0)
    ]
    kicker.draw(at: CGPoint(x: rightX, y: 180), withAttributes: kickerAttrs)
    
    // Large Title
    let titleStr = "Keep Your\nMac Awake" as NSString
    let titleStyle = NSMutableParagraphStyle()
    titleStyle.lineSpacing = 4
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 68, weight: .heavy),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        .paragraphStyle: titleStyle
    ]
    titleStr.draw(at: CGPoint(x: rightX, y: 225), withAttributes: titleAttrs)
    
    // Subtitle
    let subStr = "Prevents the system from dimming the screen or\nstarting the screensaver." as NSString
    let subStyle = NSMutableParagraphStyle()
    subStyle.lineSpacing = 6
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0),
        .paragraphStyle: subStyle
    ]
    subStr.draw(at: CGPoint(x: rightX, y: 410), withAttributes: subAttrs)
    
    // Download Pill Badge
    let badgeRect = CGRect(x: rightX, y: 505, width: 195, height: 48)
    let bPath = CGPath(roundedRect: badgeRect, cornerWidth: 24, cornerHeight: 24, transform: nil)
    ctx.setFillColor(NSColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0).cgColor)
    ctx.addPath(bPath)
    ctx.fillPath()
    
    let bAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 14, weight: .semibold),
        .foregroundColor: NSColor.white
    ]
    ("Free on GitHub" as NSString).draw(at: CGPoint(x: rightX + 46, y: 519), withAttributes: bAttrs)
    
    // Small coffee cup glyph inside badge
    drawCoffeeCup(ctx: ctx, center: CGPoint(x: rightX + 26, y: 529), size: 14, isDark: true, active: false)
    
    savePNG(image: image, path: "assets/screenshot-1.png")
    try! FileManager.default.copyItem(atPath: "assets/screenshot-1.png", toPath: "docs/assets/screenshot-1.png")
}

func generateScreenshot2() {
    let (image, ctx) = createRetinaCanvas()
    
    // Left Side: Typography
    let leftX: CGFloat = 80
    
    let kicker = "Dark Mode" as NSString
    let kickerAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold),
        .foregroundColor: NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0)
    ]
    kicker.draw(at: CGPoint(x: leftX, y: 180), withAttributes: kickerAttrs)
    
    let titleStr = "Simple\nDesign" as NSString
    let titleStyle = NSMutableParagraphStyle()
    titleStyle.lineSpacing = 4
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 68, weight: .heavy),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        .paragraphStyle: titleStyle
    ]
    titleStr.draw(at: CGPoint(x: leftX, y: 225), withAttributes: titleAttrs)
    
    let subStr = "Its simple and modern design integrates seamlessly\nwith the native environment of Apple's operating\nsystem." as NSString
    let subStyle = NSMutableParagraphStyle()
    subStyle.lineSpacing = 6
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0),
        .paragraphStyle: subStyle
    ]
    subStr.draw(at: CGPoint(x: leftX, y: 410), withAttributes: subAttrs)
    
    // Right Side: Split Screen Laptop Bezel & Dark Mode Popover
    let screenRect = CGRect(x: 520, y: 70, width: 800, height: 750)
    drawBezelAndScreen(ctx: ctx, screenRect: screenRect, isDark: true, drawSplit: true)
    
    // Menu items on light side
    let menuAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
        .foregroundColor: NSColor(white: 0.15, alpha: 1.0)
    ]
    ("Finder   File   Edit   View   Window" as NSString).draw(at: CGPoint(x: 550, y: 80), withAttributes: menuAttrs)
    
    // Coffee cup on dark side
    let cupCenter = CGPoint(x: 885, y: 88)
    drawCoffeeCup(ctx: ctx, center: cupCenter, size: 20, isDark: true, active: true)
    drawSystemIcons(ctx: ctx, startX: 925, y: 88, isDark: true)
    
    // Dark mode popover hanging below coffee cup
    let popRect = CGRect(x: 825, y: 125, width: 285, height: 245)
    drawPopover(ctx: ctx, rect: popRect, isDark: true, activeDurationMinutes: 15)
    
    savePNG(image: image, path: "assets/screenshot-2.png")
    try! FileManager.default.copyItem(atPath: "assets/screenshot-2.png", toPath: "docs/assets/screenshot-2.png")
}

func generateScreenshot3() {
    let (image, ctx) = createRetinaCanvas()
    
    // Left: Screen Bezel & Expanded Settings Popover
    let screenRect = CGRect(x: -80, y: 70, width: 620, height: 750)
    drawBezelAndScreen(ctx: ctx, screenRect: screenRect, isDark: true)
    
    let cupCenter = CGPoint(x: 105, y: 88)
    drawCoffeeCup(ctx: ctx, center: cupCenter, size: 20, isDark: true, active: true)
    drawSystemIcons(ctx: ctx, startX: 145, y: 88, isDark: true)
    
    // Popover with Settings Expanded!
    let popRect = CGRect(x: 45, y: 125, width: 300, height: 535)
    drawPopover(ctx: ctx, rect: popRect, isDark: true, activeDurationMinutes: 0, isExpandedSettings: true)
    
    // Right Side: Typography
    let rightX: CGFloat = 630
    
    let kicker = "Set Your Preferences" as NSString
    let kickerAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold),
        .foregroundColor: NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0)
    ]
    kicker.draw(at: CGPoint(x: rightX, y: 180), withAttributes: kickerAttrs)
    
    let titleStr = "Advanced\nOptions" as NSString
    let titleStyle = NSMutableParagraphStyle()
    titleStyle.lineSpacing = 4
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 68, weight: .heavy),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        .paragraphStyle: titleStyle
    ]
    titleStr.draw(at: CGPoint(x: rightX, y: 225), withAttributes: titleAttrs)
    
    let subStr = "Customize the app to your needs with a variety of\nnative macOS preferences." as NSString
    let subStyle = NSMutableParagraphStyle()
    subStyle.lineSpacing = 6
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0),
        .paragraphStyle: subStyle
    ]
    subStr.draw(at: CGPoint(x: rightX, y: 410), withAttributes: subAttrs)
    
    // "NEW" Feature Pill
    let pillRect = CGRect(x: rightX, y: 495, width: 280, height: 38)
    let pPath = CGPath(roundedRect: pillRect, cornerWidth: 19, cornerHeight: 19, transform: nil)
    ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 0.12).cgColor)
    ctx.addPath(pPath)
    ctx.fillPath()
    
    // "NEW" tag inside pill
    let tagRect = CGRect(x: rightX + 6, y: 499, width: 48, height: 30)
    let tPath = CGPath(roundedRect: tagRect, cornerWidth: 15, cornerHeight: 15, transform: nil)
    ctx.setFillColor(NSColor(red: 0.00, green: 0.48, blue: 1.0, alpha: 1.0).cgColor)
    ctx.addPath(tPath)
    ctx.fillPath()
    
    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 11, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    ("NEW" as NSString).draw(at: CGPoint(x: rightX + 17, y: 507), withAttributes: tagAttrs)
    
    let pillTextAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
        .foregroundColor: NSColor(red: 0.00, green: 0.38, blue: 0.85, alpha: 1.0)
    ]
    ("Keep Awake with Lid Closed" as NSString).draw(at: CGPoint(x: rightX + 62, y: 505), withAttributes: pillTextAttrs)
    
    savePNG(image: image, path: "assets/screenshot-3.png")
    try! FileManager.default.copyItem(atPath: "assets/screenshot-3.png", toPath: "docs/assets/screenshot-3.png")
}

func generateScreenshot4() {
    let (image, ctx) = createRetinaCanvas()
    
    // Left: Screen Bezel with Magnifying Lens Zoom
    let screenRect = CGRect(x: -80, y: 70, width: 620, height: 750)
    drawBezelAndScreen(ctx: ctx, screenRect: screenRect, isDark: false)
    
    let cupCenter = CGPoint(x: 105, y: 88)
    drawCoffeeCup(ctx: ctx, center: cupCenter, size: 20, isDark: false, active: true)
    drawSystemIcons(ctx: ctx, startX: 145, y: 88, isDark: false)
    
    // Circular Magnifying Glass Lens overlapping the Menu Bar
    let lensCenter = CGPoint(x: 190, y: 175)
    let lensRadius: CGFloat = 135
    let lensRect = CGRect(x: lensCenter.x - lensRadius, y: lensCenter.y - lensRadius, width: lensRadius * 2, height: lensRadius * 2)
    
    // Lens Ambient Drop Shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 18), blur: 32, color: NSColor(white: 0, alpha: 0.30).cgColor)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fillEllipse(in: lensRect)
    ctx.restoreGState()
    
    // Inner Zoom Content (Clipped to Lens Circle)
    ctx.saveGState()
    ctx.addEllipse(in: lensRect.insetBy(dx: 7, dy: 7))
    ctx.clip()
    
    // Zoomed Wallpaper Background
    let zoomWPRect = CGRect(x: lensCenter.x - 220, y: lensCenter.y - 220, width: 440, height: 440)
    drawLightWallpaper(ctx: ctx, rect: zoomWPRect)
    
    // Zoomed Menu Bar
    let zMenuBarRect = CGRect(x: zoomWPRect.minX, y: lensCenter.y - 50, width: 440, height: 80)
    ctx.setFillColor(NSColor(white: 1.0, alpha: 0.38).cgColor)
    ctx.fill(zMenuBarRect)
    
    // Magnified Coffee Cup (2.5x larger with rich steam!)
    let zCupCenter = CGPoint(x: lensCenter.x - 30, y: lensCenter.y - 8)
    drawCoffeeCup(ctx: ctx, center: zCupCenter, size: 48, isDark: false, active: true)
    
    // Magnified Wi-Fi icon next to it
    drawSystemIcons(ctx: ctx, startX: lensCenter.x + 35, y: lensCenter.y - 8, isDark: false)
    
    ctx.restoreGState()
    
    // Lens White Rim & Subtle Stroke
    ctx.saveGState()
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(7)
    ctx.strokeEllipse(in: lensRect.insetBy(dx: 3.5, dy: 3.5))
    
    ctx.setStrokeColor(NSColor(white: 0, alpha: 0.10).cgColor)
    ctx.setLineWidth(1)
    ctx.strokeEllipse(in: lensRect)
    ctx.restoreGState()
    
    // Right Side: Typography
    let rightX: CGFloat = 630
    
    let kicker = "Menu Bar App" as NSString
    let kickerAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold),
        .foregroundColor: NSColor(red: 0.85, green: 0.55, blue: 0.05, alpha: 1.0)
    ]
    kicker.draw(at: CGPoint(x: rightX, y: 180), withAttributes: kickerAttrs)
    
    let titleStr = "Quick\nAccess" as NSString
    let titleStyle = NSMutableParagraphStyle()
    titleStyle.lineSpacing = 4
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 68, weight: .heavy),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        .paragraphStyle: titleStyle
    ]
    titleStr.draw(at: CGPoint(x: rightX, y: 225), withAttributes: titleAttrs)
    
    let subStr = "Easily accessible in your menu bar without the need\nof a dock icon." as NSString
    let subStyle = NSMutableParagraphStyle()
    subStyle.lineSpacing = 6
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0),
        .paragraphStyle: subStyle
    ]
    subStr.draw(at: CGPoint(x: rightX, y: 410), withAttributes: subAttrs)
    
    savePNG(image: image, path: "assets/screenshot-4.png")
    try! FileManager.default.copyItem(atPath: "assets/screenshot-4.png", toPath: "docs/assets/screenshot-4.png")
}

func generateScreenshot5() {
    let (image, ctx) = createRetinaCanvas()
    
    // Left Side: Typography & Pricing Comparison
    let leftX: CGFloat = 80
    
    let kicker = "Always Up To Date" as NSString
    let kickerAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold),
        .foregroundColor: NSColor(red: 0.85, green: 0.55, blue: 0.05, alpha: 1.0)
    ]
    kicker.draw(at: CGPoint(x: leftX, y: 140), withAttributes: kickerAttrs)
    
    let titleStr = "Frequent\nUpdates" as NSString
    let titleStyle = NSMutableParagraphStyle()
    titleStyle.lineSpacing = 4
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 68, weight: .heavy),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
        .paragraphStyle: titleStyle
    ]
    titleStr.draw(at: CGPoint(x: leftX, y: 185), withAttributes: titleAttrs)
    
    let subStr = "Cafaine is 100% free and open-source forever.\nCreated with love by Hassan Elkady. We regularly\nupdate the app based on your feedback." as NSString
    let subStyle = NSMutableParagraphStyle()
    subStyle.lineSpacing = 6
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .regular),
        .foregroundColor: NSColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0),
        .paragraphStyle: subStyle
    ]
    subStr.draw(at: CGPoint(x: leftX, y: 370), withAttributes: subAttrs)
    
    // Pricing Comparison Box (Anti-AI-UI, Clean Apple contrast)
    let compBox = CGRect(x: leftX, y: 475, width: 440, height: 110)
    let compPath = CGPath(roundedRect: compBox, cornerWidth: 14, cornerHeight: 14, transform: nil)
    ctx.setFillColor(NSColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0).cgColor)
    ctx.addPath(compPath)
    ctx.fillPath()
    ctx.setStrokeColor(NSColor(white: 0, alpha: 0.08).cgColor)
    ctx.setLineWidth(1)
    ctx.addPath(compPath)
    ctx.strokePath()
    
    // Row 1: App Store Commercial
    let appStoreLabel = "Commercial Mac App Store Price:" as NSString
    appStoreLabel.draw(at: CGPoint(x: leftX + 18, y: 492), withAttributes: [
        .font: NSFont.systemFont(ofSize: 14, weight: .regular),
        .foregroundColor: NSColor(white: 0.4, alpha: 1.0)
    ])
    let appStorePrice = "$3.99" as NSString
    let strikeAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 15, weight: .semibold),
        .foregroundColor: NSColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 1.0),
        .strikethroughStyle: NSUnderlineStyle.single.rawValue
    ]
    appStorePrice.draw(at: CGPoint(x: compBox.maxX - 65, y: 492), withAttributes: strikeAttrs)
    
    // Divider
    ctx.setStrokeColor(NSColor(white: 0, alpha: 0.08).cgColor)
    ctx.setLineWidth(1)
    ctx.move(to: CGPoint(x: leftX + 18, y: 526))
    ctx.addLine(to: CGPoint(x: compBox.maxX - 18, y: 526))
    ctx.strokePath()
    
    // Row 2: Cafaine Open Source
    let cafaineLabel = "Cafaine by Hassan Elkady:" as NSString
    cafaineLabel.draw(at: CGPoint(x: leftX + 18, y: 546), withAttributes: [
        .font: NSFont.systemFont(ofSize: 14, weight: .bold),
        .foregroundColor: NSColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
    ])
    let cafainePrice = "$0.00 Free" as NSString
    cafainePrice.draw(at: CGPoint(x: compBox.maxX - 95, y: 546), withAttributes: [
        .font: NSFont.systemFont(ofSize: 15, weight: .bold),
        .foregroundColor: NSColor(red: 0.00, green: 0.65, blue: 0.35, alpha: 1.0)
    ])
    
    // Website link bottom left
    let siteAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 16, weight: .bold),
        .foregroundColor: NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0)
    ]
    ("local-over.github.io/decaf" as NSString).draw(at: CGPoint(x: leftX, y: 640), withAttributes: siteAttrs)
    
    // Right Side: Diagonal Wallpaper Sweep & Glowing 3D App Icon
    ctx.saveGState()
    let sweepPath = CGMutablePath()
    sweepPath.move(to: CGPoint(x: 580, y: 0))
    sweepPath.addLine(to: CGPoint(x: canvasWidth, y: 0))
    sweepPath.addLine(to: CGPoint(x: canvasWidth, y: canvasHeight))
    sweepPath.addLine(to: CGPoint(x: 740, y: canvasHeight))
    sweepPath.closeSubpath()
    ctx.addPath(sweepPath)
    ctx.clip()
    
    drawLightWallpaper(ctx: ctx, rect: CGRect(x: 550, y: 0, width: canvasWidth - 550, height: canvasHeight))
    ctx.restoreGState()
    
    // Render Cafaine App Icon using High-Res icon.png
    let iconSize: CGFloat = 280
    let iconRect = CGRect(x: 820, y: 240, width: iconSize, height: iconSize)
    
    if let iconImage = NSImage(contentsOfFile: "assets/icon.png") {
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 26), blur: 44, color: NSColor(red: 0.00, green: 0.20, blue: 0.60, alpha: 0.40).cgColor)
        iconImage.draw(in: iconRect)
        ctx.restoreGState()
    }
    
    savePNG(image: image, path: "assets/screenshot-5.png")
    try! FileManager.default.copyItem(atPath: "assets/screenshot-5.png", toPath: "docs/assets/screenshot-5.png")
}

func generateSliderGIF() {
    print("Generating animated slider GIF for README and website...")
    let gifURL = URL(fileURLWithPath: "assets/slider.gif")
    let targetWidth = 960
    let targetHeight = 600
    
    guard let dest = CGImageDestinationCreateWithURL(gifURL as CFURL, UTType.gif.identifier as CFString, 5, nil) else {
        print("Failed to create GIF destination")
        return
    }
    
    let gifProps = [
        kCGImagePropertyGIFDictionary as String: [
            kCGImagePropertyGIFLoopCount as String: 0
        ]
    ] as CFDictionary
    CGImageDestinationSetProperties(dest, gifProps)
    
    let frameProps = [
        kCGImagePropertyGIFDictionary as String: [
            kCGImagePropertyGIFDelayTime as String: 3.2
        ]
    ] as CFDictionary
    
    for i in 1...5 {
        guard let img = NSImage(contentsOfFile: "assets/screenshot-\(i).png") else { continue }
        
        let resized = NSImage(size: NSSize(width: targetWidth, height: targetHeight))
        resized.lockFocus()
        img.draw(in: NSRect(x: 0, y: 0, width: targetWidth, height: targetHeight),
                 from: NSRect(origin: .zero, size: img.size),
                 operation: .copy,
                 fraction: 1.0)
        resized.unlockFocus()
        
        if let cgImg = resized.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            CGImageDestinationAddImage(dest, cgImg, frameProps)
        }
    }
    
    if CGImageDestinationFinalize(dest) {
        try? FileManager.default.removeItem(atPath: "docs/assets/slider.gif")
        try? FileManager.default.copyItem(atPath: "assets/slider.gif", toPath: "docs/assets/slider.gif")
        print("Successfully created assets/slider.gif and docs/assets/slider.gif!")
    }
}

// MARK: - Execute

print("Generating 5 high-resolution App Store screenshots...")
try? FileManager.default.createDirectory(atPath: "assets", withIntermediateDirectories: true)
try? FileManager.default.createDirectory(atPath: "docs/assets", withIntermediateDirectories: true)

// Remove old files if any
for i in 1...5 {
    try? FileManager.default.removeItem(atPath: "assets/screenshot-\(i).png")
    try? FileManager.default.removeItem(atPath: "docs/assets/screenshot-\(i).png")
}

generateScreenshot1()
generateScreenshot2()
generateScreenshot3()
generateScreenshot4()
generateScreenshot5()
generateSliderGIF()

print("All screenshots and slider GIF successfully generated!")
