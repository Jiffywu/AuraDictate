import AppKit
import Foundation

let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let files: [(String, Int)] = [("icon_16x16.png",16), ("icon_16x16@2x.png",32), ("icon_32x32.png",32), ("icon_32x32@2x.png",64), ("icon_128x128.png",128), ("icon_128x128@2x.png",256), ("icon_256x256.png",256), ("icon_256x256@2x.png",512), ("icon_512x512.png",512), ("icon_512x512@2x.png",1024)]
for (name, size) in files {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    let s = CGFloat(size) / 100
    NSColor(srgbRed: 0.055, green: 0.068, blue: 0.095, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 4*s, y: 4*s, width: 92*s, height: 92*s), xRadius: 22*s, yRadius: 22*s).fill()
    NSColor(srgbRed: 224/255, green: 71/255, blue: 85/255, alpha: 1).setStroke()
    let mark = NSBezierPath()
    mark.lineWidth = 5*s
    mark.lineCapStyle = .round
    mark.move(to: NSPoint(x: 21*s, y: 46*s))
    mark.curve(to: NSPoint(x: 79*s, y: 46*s), controlPoint1: NSPoint(x: 21*s, y: 83*s), controlPoint2: NSPoint(x: 79*s, y: 83*s))
    for (i, height) in [14.0, 23.0, 34.0, 23.0, 14.0].enumerated() {
        let x = (29 + CGFloat(i) * 10.5)*s
        mark.move(to: NSPoint(x: x, y: 34*s))
        mark.line(to: NSPoint(x: x, y: (34 + height)*s))
    }
    mark.stroke()
    image.unlockFocus()
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) else { fatalError("Could not render icon") }
    try png.write(to: output.appendingPathComponent(name))
}
