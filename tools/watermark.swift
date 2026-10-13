// Stamps a corner watermark onto a resized copy of an image. Used by build-art-images.sh.
// Usage: swift watermark.swift <source> <dest.jpg> <maxPixelSize> <text>
import AppKit
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
let src = URL(fileURLWithPath: args[1])
let dst = URL(fileURLWithPath: args[2])
let maxSize = Int(args[3])!
let text = args[4]

guard let source = CGImageSourceCreateWithURL(src as CFURL, nil),
      let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,   // respect EXIF orientation
        kCGImageSourceThumbnailMaxPixelSize: maxSize,
      ] as CFDictionary)
else { fatalError("cannot read \(src.path)") }

let w = image.width, h = image.height
let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))

NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)

let fontSize = CGFloat(min(w, h)) * 0.042
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.55)
shadow.shadowBlurRadius = fontSize * 0.25
shadow.shadowOffset = NSSize(width: 0, height: -fontSize * 0.05)
let attrs: [NSAttributedString.Key: Any] = [
  .font: NSFont(name: "Georgia", size: fontSize) ?? NSFont.systemFont(ofSize: fontSize),
  .foregroundColor: NSColor.white.withAlphaComponent(0.6),
  .shadow: shadow,
]
let str = NSAttributedString(string: text, attributes: attrs)
let size = str.size()
let margin = fontSize * 0.9
str.draw(at: NSPoint(x: CGFloat(w) - size.width - margin, y: margin))

let out = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(dst as CFURL, UTType.jpeg.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, out, [kCGImageDestinationLossyCompressionQuality: 0.62] as CFDictionary)
guard CGImageDestinationFinalize(dest) else { fatalError("cannot write \(dst.path)") }
