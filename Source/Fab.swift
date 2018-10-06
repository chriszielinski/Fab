//
//  Fab.swift
//  Fab.
//
// The MIT License (MIT)
//
// Original Work Copyright © 2015 Lourenço Pinheiro Marinho.
// Modified Work Copyright © 2018 Big Z Labs.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import AppKit

public typealias FabAction = (Fab) -> Void

open class Fab: NSObject {

    /// The type of the button.
    public enum Kind {
        /// A button with a solid background.
        case colored
        /// A button with a `NSVisualEffectView`-backed background.
        case visualEffect
    }

    /// The action the button should perform when tapped.
    open var action: FabAction = { $0.toggleMenu() }

    /// The angle, in radians, to rotate the button when active (expanded).
    open var buttonRotation: CGFloat = CGFloat.pi / 4

    /// The button's background color.
    open var backgroundColor: NSColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        willSet { floatButton.backgroundColor = newValue }
    }

    /// The button's background color.
    open var backgroundColorSelected: NSColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)

    /// Whether the button's drop shadow should be hidden when active (expanded).
    open var hidesButtonShadowWhenActive: Bool = true

    /// The button's drop shadow.
    open var buttonShadow: NSShadow? {
        get { return floatButton.shadow }
        set { floatButton.shadow = newValue }
    }

    /// The height of the entire expanded content. Can be used to determine the minimum window size.
    open var contentHeight: CGFloat {
        let floatButtonHeight = 15 + CGFloat(buttonDiameter)
        guard let itemCount = items?.count, itemCount > 0
            else { return floatButtonHeight }

        let itemsHeight = CGFloat(itemCount) * FabItem.viewSize.height
            + CGFloat(itemCount - 1) * itemOffset
            + buttonFirstItemOffset
        return floatButtonHeight + itemsHeight
    }

    /// Indicates if the button is active (showing its items).
    fileprivate(set) open var active: Bool = false

    /// An array of items that the button will present.
    internal var items: [FabItem]? {
        willSet {
            items?.forEach {
                $0.view.removeFromSuperview()
            }
        }
        didSet {
            placeButtonItems()
            showActive(true)
        }
    }

    /// The type of the button.
    public let kind: Kind
    /// The button, regardless of kind.
    private let button: NSView

    /// Returns the `VisualEffectButton`.
    ///
    /// - Note: Only a non-nil value when the button kind is `.visualEffect`.
    public var visualEffectButton: VisualEffectButton? {
        return button as? VisualEffectButton
    }

    /// The button that will be presented to the user.
    public var floatButton: CircularButton {
        switch kind {
        case .visualEffect:
            return visualEffectButton!.button
        case .colored:
            // swiftlint:disable:next force_cast
            return button as! CircularButton
        }
    }

    /// View that will hold the placement of the button's actions.
    fileprivate var contentView: NSView!

    /// View where the *floatButton* will be displayed.
    fileprivate weak var parentView: NSView!

    /// Blur effect that will be presented when the button is active.
    public var visualEffectView: NSVisualEffectView!

    /// The button's diameter.
    public var buttonDiameter: CGFloat = 50

    // The distance between each item action.
    public var itemOffset: CGFloat = 10

    /// The distance between the button and first item.
    public var buttonFirstItemOffset: CGFloat = 10

    /// The value to scale the button to when the cursor enters its bounds.
    public var buttonMouseOverScale: CGFloat = 1.05

    /// Whether to present the `NSVisualEffectView` when the button is active (expanded).
    public var usesVisualEffectBackground: Bool {
        get { return visualEffectView.isHidden }
        set { visualEffectView.isHidden = newValue }
    }

    public init(attachedTo view: NSView, kind: Kind, items: [FabItem]?) {
        self.kind = kind
        self.items = items
        parentView = view

        switch kind {
        case .colored:
            button = CircularButton(diameter: buttonDiameter, backgroundColor: backgroundColor)

            let shadow = NSShadow()
            shadow.shadowBlurRadius = 5
            shadow.shadowColor = .gray
            button.shadow = shadow
            button.layer!.shadowOpacity = 1
        case .visualEffect:
            button = VisualEffectButton(diameter: buttonDiameter)
            backgroundColor = .clear
            hidesButtonShadowWhenActive = false
        }

        super.init()

        floatButton.cursorTrackingHandler = { [unowned self] didCursorEnter in
            // The second value is the multiplicative inverse of the first.
            self.button.animateScaling(to: didCursorEnter ? self.buttonMouseOverScale : 1 / self.buttonMouseOverScale)
        }
        floatButton.allowsMouseDownInBounds = false
        floatButton.setButtonType(.pushOnPushOff)
        floatButton.alignment = .center
        floatButton.imagePosition = .noImage
        let buttonTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 35, weight: .semibold),
                .baselineOffset: 3,
                .kern: -1
        ]
        floatButton.attributedTitle = NSAttributedString(string: "+",
                                                         attributes: buttonTitleAttributes)
        floatButton.image = nil
        floatButton.target = self
        floatButton.action = #selector(buttonClicked)
        floatButton.postsFrameChangedNotifications = true

        contentView = ColoredView(frame: parentView.bounds,
                                  backgroundColor: .clear,
                                  shouldFlip: true)
        contentView.alphaValue = 0
        let gestureRecognizer = NSClickGestureRecognizer(target: self,
                                                         action: #selector(backgroundClicked(_:)))
        gestureRecognizer.delaysPrimaryMouseButtonEvents = false
        contentView.addGestureRecognizer(gestureRecognizer)

        visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .withinWindow
        visualEffectView.state = .active
        visualEffectView.material = .popover

        parentView.addSubview(button)
        contentView.addSubview(visualEffectView)
        parentView.addSubview(contentView, positioned: .below, relativeTo: button)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didButtonFrameChange),
                                               name: NSView.frameDidChangeNotification,
                                               object: button)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleMenu),
                                               name: .dismissFab,
                                               object: nil)

        installConstraints()
        placeButtonItems()
        showActive(true)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Methods
    open func setTitle(_ title: NSAttributedString) {
        floatButton.image = nil
        floatButton.attributedTitle = title
        floatButton.imagePosition = .noImage
    }

    open func setImage(_ image: NSImage) {
        floatButton.imagePosition = .imageOnly
        floatButton.image = image
    }

    // MARK: - Auto Layout Methods

    /// Install all the necessary constraints for the button. By the default the button will be placed at 15pts
    /// from the bottom and the 15pts from the right of its *parentView*
    fileprivate func installConstraints() {
        let views: [String: NSView] = ["floatButton": button, "parentView": parentView]
        let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[floatButton(\(buttonDiameter))]",
                                                   options: .alignAllCenterX,
                                                   metrics: nil,
                                                   views: views)
        let height = NSLayoutConstraint.constraints(withVisualFormat: "V:[floatButton(\(buttonDiameter))]",
                                                    options: .alignAllCenterX,
                                                    metrics: nil,
                                                    views: views)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraints(width)
        button.addConstraints(height)

        let trailingSpacing = NSLayoutConstraint.constraints(withVisualFormat: "V:[floatButton]-15-|",
                                                             options: .alignAllCenterX,
                                                             metrics: nil,
                                                             views: views)
        let bottomSpacing = NSLayoutConstraint.constraints(withVisualFormat: "H:[floatButton]-15-|",
                                                           options: .alignAllCenterX,
                                                           metrics: nil,
                                                           views: views)
        parentView.addConstraints(trailingSpacing)
        parentView.addConstraints(bottomSpacing)

        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: parentView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])

        installVisualEffectViewConstraints()
    }

    open func installVisualEffectViewConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Button Actions Methods

    @objc
    func buttonClicked(_ sender: NSControl) {
        button.animateScaling(to: 1)
        action(self)
    }

    // MARK: - Gesture Recognizer Methods

    @objc
    func backgroundClicked(_ gesture: NSGestureRecognizer) {
        if active {
            toggleMenu()
        }
    }

    // MARK: - Notification Methods

    @objc
    func didButtonFrameChange() {
        if active {
            toggleMenu()
        }
        placeButtonItems()
    }

    // MARK: - Custom Methods

    /// Presents or hides all the Fab's actions
    @objc
    open func toggleMenu() {
        guard !isAnimating
            else { return }

        if !active {
            placeButtonItems()
        }
        toggle()
    }

    // MARK: - Fab Items Placement

    /// Defines the position of all the Fab's actions
    fileprivate func placeButtonItems() {
        let floatButtonCenter = button.center
        items?.enumerated().forEach { (index, item) in
            item.view.removeFromSuperview()
            contentView.addSubview(item.view)

            item.view.center = CGPoint(x: floatButtonCenter.x - 83, y: floatButtonCenter.y)
        }
    }

    // MARK: - Float Menu Methods

    /// Presents or hides all the Fab's actions and changes the *active* state.
    fileprivate func toggle() {
        animateMenu()

        active.toggle()

        if hidesButtonShadowWhenActive {
            floatButton.animator().layer!.shadowOpacity = active ? 0 : 1
        }

        floatButton.backgroundColor = active ? backgroundColorSelected : backgroundColor
        floatButton.isHighlighted = active
    }

    var isAnimating: Bool = false
    fileprivate func animateMenu() {
        isAnimating = true
        let rotation: CGFloat = active ? 0 : buttonRotation
        NotificationCenter.default.post(name: .disableFabItems, object: nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true

            if self.floatButton.image == nil {
                self.floatButton.layer!.setAffineTransform(CGAffineTransform(rotationAngle: rotation))
            }

            self.showActive(false)
        }, completionHandler: {
            self.isAnimating = false
            NotificationCenter.default.post(name: .enableFabItems, object: nil)
        })
    }

    fileprivate func showActive(_ active: Bool) {
        if self.active == active {
            contentView.alphaValue = 1

            let floatButtonTopOffset = (buttonDiameter / 2)
                + (FabItem.viewSize.height / 2)
            items?.enumerated().forEach { (index, item) in
                let translation = (CGFloat(index) * -(itemOffset + FabItem.viewSize.height))
                    - floatButtonTopOffset
                    - buttonFirstItemOffset

                item.view.frame.origin.y += translation
                item.view.layer!.position.y += translation
                item.view.alphaValue = 1
            }
        } else {
            contentView.alphaValue = 0

            let floatButtonCenter = button.center
            items?.forEach { item in
                item.view.layer!.position.y += floatButtonCenter.y - item.view.center.y
                item.view.alphaValue = 0
            }
        }
    }
}
