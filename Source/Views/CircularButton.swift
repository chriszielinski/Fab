//
//  CircularButton.swift
//  Fab.
//
//  Created by Chris Zielinski on 10/4/18.
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

import Cocoa

open class CircularButton: ColoredButton, CursorTrackable {

    public let diameter: CGFloat
    public var allowsMouseDownInBounds: Bool = true
    public var ignoresMouseEvents: Bool = false

    // MARK: - Cursor Trackable

    public var cursorTrackingHandler: ((Bool) -> Void)?
    internal var trackingAreaTag: NSView.TrackingRectTag?

    public var cornerRadius: CGFloat {
        get { return layer!.cornerRadius }
        set { layer!.cornerRadius = newValue }
    }

    public init(diameter: CGFloat, backgroundColor: NSColor?) {
        self.diameter = diameter

        super.init(frame: NSRect(origin: .zero, size: CGSize(width: diameter, height: diameter)),
                   backgroundColor: backgroundColor)

        bezelStyle = .circular
        isBordered = false
        cornerRadius = CGFloat(diameter / 2)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func circularButtonContains(point: NSPoint) -> Bool {
        // Thanks Euclid.
        let radius = diameter / 2
        let origin = NSPoint(x: radius, y: radius)
        let euclideanDistance = (pow(point.x - origin.x, 2) + pow(point.y - origin.y, 2)).squareRoot()
        return euclideanDistance <= radius
    }

    override open func hitTest(_ point: NSPoint) -> NSView? {
        guard !ignoresMouseEvents
            else { return nil }

        guard !allowsMouseDownInBounds
            else { return super.hitTest(point) }

        return circularButtonContains(point: superview!.convert(point, to: self)) ? self : nil
    }

    override open func updateTrackingAreas() {
        updateCursorTrackingArea()
    }

    override open func mouseEntered(with event: NSEvent) {
        guard !ignoresMouseEvents
            else { return }

        super.mouseEntered(with: event)
        cursorTrackingHandler?(true)
    }

    override open func mouseExited(with event: NSEvent) {
        guard !ignoresMouseEvents
            else { return }

        super.mouseExited(with: event)
        cursorTrackingHandler?(false)
    }
}
