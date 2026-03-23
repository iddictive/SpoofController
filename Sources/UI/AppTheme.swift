import Cocoa

enum AppTheme {
    static let accent = NSColor(srgbRed: 0.09, green: 0.58, blue: 0.98, alpha: 1)
    static let accentSoft = NSColor(srgbRed: 0.32, green: 0.78, blue: 0.82, alpha: 1)
    static let warning = NSColor(srgbRed: 0.95, green: 0.62, blue: 0.24, alpha: 1)
    static let success = NSColor(srgbRed: 0.19, green: 0.73, blue: 0.43, alpha: 1)
    static let danger = NSColor(srgbRed: 0.91, green: 0.32, blue: 0.31, alpha: 1)
    static let cardFill = NSColor.white.withAlphaComponent(0.10)
    static let cardStroke = NSColor.white.withAlphaComponent(0.16)
    static let secondaryStroke = NSColor.black.withAlphaComponent(0.08)

    static func styleWindow(_ window: NSWindow?, minSize: NSSize? = nil) {
        guard let window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        if let minSize {
            window.minSize = minSize
        }
    }

    static func stylePrimaryButton(_ button: NSButton) {
        button.bezelStyle = .rounded
        button.wantsLayer = true
        button.layer?.cornerRadius = 12
        button.layer?.backgroundColor = accent.cgColor
        button.layer?.borderColor = accentSoft.withAlphaComponent(0.5).cgColor
        button.layer?.borderWidth = 1
        button.contentTintColor = .white
        button.font = .systemFont(ofSize: 13, weight: .semibold)
    }

    static func styleSecondaryButton(_ button: NSButton) {
        button.bezelStyle = .rounded
        button.wantsLayer = true
        button.layer?.cornerRadius = 12
        button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.08).cgColor
        button.layer?.borderColor = cardStroke.cgColor
        button.layer?.borderWidth = 1
        button.contentTintColor = .labelColor
        button.font = .systemFont(ofSize: 13, weight: .medium)
    }

    static func styleInput(_ control: NSControl) {
        control.font = .systemFont(ofSize: 13, weight: .medium)
        control.wantsLayer = true
        control.layer?.cornerRadius = 10
        control.layer?.borderWidth = 1
        control.layer?.borderColor = cardStroke.cgColor
        control.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.10).cgColor
    }

    static func makeHeadline(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .labelColor
        label.lineBreakMode = .byWordWrapping
        return label
    }

    static func makeSubtitle(_ text: String) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabelColor
        return label
    }

    static func styleCard(_ view: NSView, cornerRadius: CGFloat = 22) {
        view.wantsLayer = true
        view.layer?.cornerRadius = cornerRadius
        view.layer?.borderWidth = 1
        view.layer?.borderColor = cardStroke.cgColor
        view.layer?.backgroundColor = cardFill.cgColor
    }

    static func makeStatusBadge(text: String, color: NSColor) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.cornerRadius = 999
        container.layer?.backgroundColor = color.withAlphaComponent(0.14).cgColor
        container.layer?.borderWidth = 1
        container.layer?.borderColor = color.withAlphaComponent(0.35).cgColor

        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])
        return container
    }
}

final class GradientBackdropView: NSView {
    private let gradientLayer = CAGradientLayer()
    private let glowLayer = CAShapeLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        layer?.addSublayer(gradientLayer)
        layer?.addSublayer(glowLayer)
        gradientLayer.colors = [
            NSColor(srgbRed: 0.06, green: 0.09, blue: 0.14, alpha: 1).cgColor,
            NSColor(srgbRed: 0.11, green: 0.16, blue: 0.24, alpha: 1).cgColor,
            NSColor(srgbRed: 0.05, green: 0.11, blue: 0.18, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        glowLayer.fillColor = NSColor.white.withAlphaComponent(0.04).cgColor
    }

    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
        let insetBounds = bounds.insetBy(dx: bounds.width * 0.18, dy: bounds.height * 0.10)
        glowLayer.path = CGPath(ellipseIn: insetBounds, transform: nil)
    }
}

final class SurfaceCardView: NSView {
    let stack = NSStackView()

    init(spacing: CGFloat = 14) {
        super.init(frame: .zero)
        AppTheme.styleCard(self)
        translatesAutoresizingMaskIntoConstraints = false

        stack.orientation = .vertical
        stack.spacing = spacing
        stack.alignment = .leading
        addSubview(stack)
        stack.fill(parent: self, padding: 20)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MetricCardView: NSView {
    private let titleLabel = NSTextField(labelWithString: "")
    private let valueLabel = NSTextField(labelWithString: "—")
    private let unitLabel = NSTextField(labelWithString: "")

    init(title: String, unit: String) {
        super.init(frame: .zero)
        AppTheme.styleCard(self, cornerRadius: 20)

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        addSubview(stack)
        stack.fill(parent: self, padding: 18)

        titleLabel.stringValue = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .secondaryLabelColor

        valueLabel.font = .systemFont(ofSize: 30, weight: .bold)
        valueLabel.textColor = .labelColor

        unitLabel.stringValue = unit
        unitLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        unitLabel.textColor = .secondaryLabelColor

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(unitLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: String) {
        valueLabel.stringValue = value
    }
}

extension NSView {
    func fill(parent: NSView, padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding)
        ])
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
