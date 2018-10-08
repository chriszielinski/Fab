//
//  FabItem.swift
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

import AppKit

public typealias FabItemAction = (FabItem) -> Void

open class FabItem: NSObject {

    /// Size needed for the *view* property presente the item's content.
    static let viewSize = CGSize(width: 200, height: 35)

    /// The action the item should perform when tapped.
    public var action: FabItemAction?

    /// The item's button diameter. Default diameter of 35.
    public let buttonDiameter: CGFloat = 35

    /// The distance between the item's label and button.
    public var labelButtonOffset: CGFloat = 0

    /// Whether the menu is dismissed when this item is selected.
    public var dismissMenuOnSelection: Bool = true

    /// The value to scale the button to when the cursor enters its bounds.
    public var buttonMouseOverScale: CGFloat = 1.05

    /// Whether the item ignores mouse down events.
    public var isDisabled: Bool = false

    /// Description of the item's action.
    open var text: String {
        get { return label.stringValue }
        set { label.stringValue = newValue }
    }
    /// View that will hold the item's button and label.
    internal var view: ColoredView!

    /// Label that contain the item's *text*.
    fileprivate var label: NSTextField!

    /// Main button that will perform the defined action.
    fileprivate var button: CircularButton!

    fileprivate var labelBackground: ColoredView!
    fileprivate let backgroundInset = CGSize(width: 10, height: 10)

    /// Whether the item's right button should be hidden.
    fileprivate var shouldHideButton: Bool {
        return button.image == nil && button.title.isEmpty
    }

    /// Creates a new Fab item with an image and optional label.
    ///
    /// - Parameters:
    ///   - label: The string to display in the label.
    ///   - emoji: The emoji to display in the button.
    public init(label: String?, image: NSImage, action: FabItemAction? = nil) {
        super.init()

        createButton(label: label, image: image, buttonIcon: nil)
        self.action = action
    }

    /// Creates a new Fab item with a label and button from an attributed string.
    ///
    /// - Parameters:
    ///   - label: The string to display in the label.
    ///   - buttonIcon: The attributed string to display in the button. Should be a single character.
    public init(label: String?, buttonIcon: NSAttributedString, action: FabItemAction? = nil) {
        super.init()

        createButton(label: label, image: nil, buttonIcon: buttonIcon)
        self.action = action
    }

    /// Creates a new Fab item with only a label.
    ///
    /// - Parameter label: The string to display in the label.
    public init(label: String, action: FabItemAction? = nil) {
        super.init()

        createButton(label: label, image: nil, buttonIcon: nil)
        self.action = action
    }

    /// A convenience initializer that creates a new Fab item with an emoji and optional label.
    ///
    /// Applies some default formatting to the button that should satisfy most emojis.
    ///
    /// - Parameters:
    ///   - label: The string to display in the label.
    ///   - emoji: The emoji to display in the button.
    public convenience init(label: String?, emoji: String, action: FabItemAction? = nil) {
        let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 15),
                .baselineOffset: -1
        ]
        let attributedString = NSAttributedString(string: emoji, attributes: emojiAttributes)

        self.init(label: label, buttonIcon: attributedString, action: action)
    }

    func createButton(label optionalTitle: String?, image: NSImage?, buttonIcon: NSAttributedString?) {
        let cursorTrackingHandler: ((Bool) -> Void) = { [unowned self] didCursorEnter in
            // The second value is the multiplicative inverse of the first.
            self.view.animateScaling(to: didCursorEnter ? self.buttonMouseOverScale : 1 / self.buttonMouseOverScale)
        }

        view = ColoredView(frame: CGRect(origin: .zero, size: FabItem.viewSize),
                           backgroundColor: .clear,
                           shouldFlip: true)
        view.alphaValue = 0

        let buttonWidth = FabItem.viewSize.width - buttonDiameter
        button = CircularButton(diameter: buttonDiameter, backgroundColor: .controlColor)
        button.setFrameOrigin(CGPoint(x: buttonWidth, y: 0))
        button.setButtonType(.onOff)
        button.bezelStyle = .circular
        button.isBordered = false
        button.target = self
        button.action = #selector(itemClicked(_:))
        button.cursorTrackingHandler = cursorTrackingHandler

        if let image = image {
            button.imagePosition = .imageOnly
            button.image = image
        } else if let buttonIcon = buttonIcon {
            button.imagePosition = .noImage
            button.attributedTitle = buttonIcon
        }

        if let text = optionalTitle, text.trimmingCharacters(in: .whitespaces).isEmpty == false {
            label = NSTextField(labelWithString: text)
            label.font = NSFont.controlContentFont(ofSize: 13)
            label.alignment = .right

            label.sizeToFit()

            labelBackground = ColoredView(frame: label.frame,
                                          backgroundColor: .controlColor,
                                          shouldFlip: true)
            labelBackground.cornerRadius = 3
            labelBackground.cursorTrackingHandler = cursorTrackingHandler

            let clickGestureRecognizer = NSClickGestureRecognizer(target: self,
                                                                  action: #selector(itemClicked(_:)))
            clickGestureRecognizer.delaysPrimaryMouseButtonEvents = false
            labelBackground.addGestureRecognizer(clickGestureRecognizer)

            // Adjust the label's background inset
            labelBackground.frame.size.width = label.frame.size.width + backgroundInset.width
            labelBackground.frame.size.height = label.frame.size.height + backgroundInset.height
            label.frame.origin.x += backgroundInset.width / 2
            label.frame.origin.y += backgroundInset.height / 2

            // Adjust label's background position
            let buttonOffset: CGFloat = shouldHideButton ? FabItem.viewSize.width - backgroundInset.width: 150
            labelBackground.frame.origin.x = CGFloat((buttonOffset - labelButtonOffset) - label.frame.size.width)
            labelBackground.center.y = view.center.y
            labelBackground.addSubview(label)

            view.addSubview(labelBackground)
        }

        if !shouldHideButton {
            view.addSubview(button)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disableFabItem),
                                               name: .disableFabItems,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enableFabItem),
                                               name: .enableFabItems,
                                               object: nil)
    }

    // MARK: - Action Methods

    @objc func itemClicked(_ sender: Any) {
        if dismissMenuOnSelection {
            NotificationCenter.default.post(name: .dismissFab, object: nil)
        }

        action?(self)
    }

    // MARK: - Notification Methods

    @objc
    func disableFabItem() {
        changeItemState(isEnabled: false)
    }

    @objc
    func enableFabItem() {
        changeItemState(isEnabled: true)
    }

    func changeItemState(isEnabled: Bool) {
        button.ignoresMouseEvents = !isEnabled
        labelBackground.ignoresMouseEvents = !isEnabled
    }
}
