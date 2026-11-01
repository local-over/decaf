import AppKit

public final class MenuBarIconGenerator {
    public static let shared = MenuBarIconGenerator()
    
    private init() {}
    
    public func inactiveIcon() -> NSImage {
        let size: CGFloat = 18
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        
        let strokeColor = NSColor.black
        strokeColor.setStroke()
        
        let cupWidth: CGFloat = 10
        let cupHeight: CGFloat = 7.5
        let startX: CGFloat = 2.5
        let startY: CGFloat = 3.5
        
        // Saucer
        let saucer = NSBezierPath(roundedRect: NSRect(x: 1.5, y: 2.0, width: 12.5, height: 1.5), xRadius: 0.75, yRadius: 0.75)
        strokeColor.setFill()
        saucer.fill()
        
        // Cup Outline
        let cupRect = NSRect(x: startX, y: startY, width: cupWidth, height: cupHeight)
        let cupPath = NSBezierPath(roundedRect: cupRect, xRadius: 2.5, yRadius: 2.5)
        cupPath.lineWidth = 1.3
        cupPath.stroke()
        
        // Handle
        let handleRect = NSRect(x: cupRect.maxX - 0.5, y: cupRect.midY - 2.0, width: 3.2, height: 4.2)
        let handlePath = NSBezierPath(roundedRect: handleRect, xRadius: 1.6, yRadius: 1.6)
        handlePath.lineWidth = 1.2
        handlePath.stroke()
        
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
    
    public func activeIcon(frame: Int, colored: Bool = false) -> NSImage {
        let size: CGFloat = 18
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        
        let fillColor: NSColor
        if colored {
            fillColor = NSColor(red: 0.00, green: 0.682, blue: 0.949, alpha: 1.0)
        } else {
            fillColor = NSColor.black
        }
        fillColor.setFill()
        fillColor.setStroke()
        
        let cupWidth: CGFloat = 10
        let cupHeight: CGFloat = 7.5
        let startX: CGFloat = 2.5
        let startY: CGFloat = 3.5
        
        // Saucer
        let saucer = NSBezierPath(roundedRect: NSRect(x: 1.5, y: 2.0, width: 12.5, height: 1.5), xRadius: 0.75, yRadius: 0.75)
        saucer.fill()
        
        // Filled Cup
        let cupRect = NSRect(x: startX, y: startY, width: cupWidth, height: cupHeight)
        let cupPath = NSBezierPath(roundedRect: cupRect, xRadius: 2.5, yRadius: 2.5)
        cupPath.fill()
        
        // Handle
        let handleRect = NSRect(x: cupRect.maxX - 0.5, y: cupRect.midY - 2.0, width: 3.2, height: 4.2)
        let handlePath = NSBezierPath(roundedRect: handleRect, xRadius: 1.6, yRadius: 1.6)
        handlePath.lineWidth = 1.2
        handlePath.stroke()
        
        // Animated Rising Steam (Phase shifted based on frame 0...3)
        let phase = CGFloat(frame % 4)
        let steamBaseY = cupRect.maxY + 1.2
        
        for i in 0..<2 {
            let steam = NSBezierPath()
            let xOffset: CGFloat = (i == 0) ? -2.2 : 2.2
            let x = cupRect.midX + xOffset
            let progress = (CGFloat(i) * 0.5 + phase * 0.25).truncatingRemainder(dividingBy: 1.0)
            
            let curY = steamBaseY + progress * 3.5
            let curH: CGFloat = 2.5
            
            steam.move(to: NSPoint(x: x, y: curY))
            steam.curve(
                to: NSPoint(x: x, y: min(17.0, curY + curH)),
                controlPoint1: NSPoint(x: x - 0.8, y: curY + curH * 0.4),
                controlPoint2: NSPoint(x: x + 0.8, y: curY + curH * 0.7)
            )
            steam.lineWidth = 1.1
            steam.lineCapStyle = .round
            steam.stroke()
        }
        
        image.unlockFocus()
        if !colored {
            image.isTemplate = true
        }
        return image
    }
}
