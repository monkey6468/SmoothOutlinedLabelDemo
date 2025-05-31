//
//  SmoothOutlinedLabel.swift
//  SmoothOutlinedLabelDemo
//
//  Created by xwh on 2025/5/31.
//

import UIKit

@IBDesignable
class SmoothOutlinedLabel: UIView {
    
    // MARK: - Inspectables

    @IBInspectable var text: String = "" {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var font: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var shadowBlur: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var strokeColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var textColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var strokeWidth: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var lineSpacing: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var letterSpacing: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var lineLimit: Int = 0 { // 0 表示不限制
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var paddingTop: CGFloat = 5 { didSet { setNeedsDisplay() } }
    @IBInspectable var paddingLeft: CGFloat = 5 { didSet { setNeedsDisplay() } }
    @IBInspectable var paddingBottom: CGFloat = 5 { didSet { setNeedsDisplay() } }
    @IBInspectable var paddingRight: CGFloat = 5 { didSet { setNeedsDisplay() } }

    private var textInsets: UIEdgeInsets {
        return UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
    }
    
    // MARK: - Private Properties

    private var glyphPaths: [CGPath] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isOpaque = false
        backgroundColor = .clear
    }

    // MARK: - Glyph Path

    private func createGlyphPaths(for line: CTLine, at origin: CGPoint) {
        glyphPaths.removeAll()

        let runs = CTLineGetGlyphRuns(line) as NSArray
        for runIndex in 0..<runs.count {
            let run = runs[runIndex] as! CTRun
            let runFont = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont
            let glyphCount = CTRunGetGlyphCount(run)

            for glyphIndex in 0..<glyphCount {
                var glyph = CGGlyph()
                var position = CGPoint.zero
                CTRunGetGlyphs(run, CFRangeMake(glyphIndex, 1), &glyph)
                CTRunGetPositions(run, CFRangeMake(glyphIndex, 1), &position)

                let offset = CGPoint(x: origin.x + position.x, y: origin.y + position.y)
                guard let path = CTFontCreatePathForGlyph(runFont, glyph, nil) else { continue }
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                if let transformed = path.copy(using: &transform) {
                    glyphPaths.append(transformed)
                }
            }
        }
    }

    private func drawGlyphPaths(in context: CGContext) {
        context.saveGState()

        // 阴影配置
        if shadowColor != .clear {
            context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
        }

        for path in glyphPaths {
            let bezier = UIBezierPath(cgPath: path)
            strokeColor.setStroke()
            bezier.lineWidth = strokeWidth
            bezier.lineJoinStyle = .round
            bezier.lineCapStyle = .round
            bezier.stroke()
            textColor.setFill()
            bezier.fill()
        }

        context.restoreGState()
    }

    // MARK: - Draw

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !text.isEmpty else { return }
        ctx.clear(rect)

        let drawRect = rect.inset(by: textInsets)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .kern: letterSpacing,
            .paragraphStyle: paragraphStyle
        ]
        let attrString = NSAttributedString(string: text, attributes: attributes)

        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let path = CGPath(rect: drawRect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)

        ctx.saveGState()
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)

        let lines = CTFrameGetLines(frame)
        let count = CFArrayGetCount(lines)
        let drawCount = (lineLimit > 0) ? min(lineLimit, count) : count

        var origins = Array(repeating: CGPoint.zero, count: drawCount)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, drawCount), &origins)

        for i in 0..<drawCount {
            let line = unsafeBitCast(CFArrayGetValueAtIndex(lines, i), to: CTLine.self)
            var origin = origins[i]
            origin.x += textInsets.left
            origin.y -= textInsets.bottom
            createGlyphPaths(for: line, at: origin)
            drawGlyphPaths(in: ctx)
        }

        ctx.restoreGState()
    }
}
