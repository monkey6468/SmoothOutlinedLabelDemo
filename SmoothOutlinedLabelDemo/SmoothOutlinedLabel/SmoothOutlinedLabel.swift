//
//  SmoothOutlinedLabel.swift
//  SmoothOutlinedLabelDemo
//
//  Created by xwh on 2025/5/31.
//

import UIKit

@IBDesignable
class SmoothOutlinedLabel: UIView {
    
    // MARK: - Enums

    enum HorizontalAlignment: Int {
        case left = 0, center = 1, right = 2
    }

    enum VerticalAlignment: Int {
        case top = 0, middle = 1, bottom = 2
    }

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
    
    @IBInspectable var lineSpacing: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var letterSpacing: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var lineLimit: Int = 1 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var horizontalAlignmentRaw: Int = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var verticalAlignmentRaw: Int = 0 {
        didSet { setNeedsDisplay() }
    }

    var horizontalAlignment: HorizontalAlignment {
        HorizontalAlignment(rawValue: horizontalAlignmentRaw) ?? .left
    }

    var verticalAlignment: VerticalAlignment {
        VerticalAlignment(rawValue: verticalAlignmentRaw) ?? .middle
    }

    // MARK: - Private

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

    // MARK: - Glyph Paths

    private func createGlyphPaths(for line: CTLine, at origin: CGPoint) {
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

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !text.isEmpty else { return }
        ctx.clear(rect)

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
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)

        ctx.saveGState()
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)

        let lines = CTFrameGetLines(frame) as! [CTLine]
        let count = min(lineLimit > 0 ? lineLimit : lines.count, lines.count)

        var origins = Array(repeating: CGPoint.zero, count: count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, count), &origins)

        // 垂直对齐：计算整体文本高度
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        var totalHeight: CGFloat = 0
        for line in lines.prefix(count) {
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            totalHeight += ascent + descent + lineSpacing
        }
        totalHeight -= lineSpacing

        let yOffset: CGFloat = {
            switch verticalAlignment {
            case .top: return 0
            case .middle: return (bounds.height - totalHeight) / 2
            case .bottom: return bounds.height - totalHeight
            }
        }()

        glyphPaths.removeAll()

        for i in 0..<count {
            let line = lines[i]
            var origin = origins[i]

            // 水平对齐
            let flush: CGFloat = {
                switch horizontalAlignment {
                case .left: return 0.0
                case .center: return 0.5
                case .right: return 1.0
                }
            }()
            let penOffset = CTLineGetPenOffsetForFlush(line, flush, Double(bounds.width))
            origin.x = CGFloat(penOffset)
            origin.y -= yOffset

            createGlyphPaths(for: line, at: origin)
            drawGlyphPaths(in: ctx)
        }

        ctx.restoreGState()
    }
}
