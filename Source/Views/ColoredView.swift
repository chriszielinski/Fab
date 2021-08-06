//
//  ColoredView.swift
//  Fab.
//
//  Created by Chris Zielinski on 10/3/18.
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

final class ColoredView: FlippableView, CursorTrackable {

    var ignoresMouseEvents: Bool = false {
        didSet { gestureRecognizers.setEnabled(to: !ignoresMouseEvents) }
    }
    let backgroundColor: NSColor

    // MARK: - Cursor Trackable

    var cursorTrackingHandler: ((ColoredView, Bool) -> Void)?
    var trackingAreaTag: NSView.TrackingRectTag?

    var cornerRadius: CGFloat {
        get { return layer!.cornerRadius }
        set { layer!.cornerRadius = newValue }
    }

    override var wantsUpdateLayer: Bool {
        return true
    }

    init(frame frameRect: NSRect, backgroundColor: NSColor, shouldFlip: Bool = false) {
        self.backgroundColor = backgroundColor

        super.init(frame: frameRect, shouldFlip: shouldFlip)

        wantsLayer = true
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateLayer() {
        setAnchorPointToCenter()
        layer!.backgroundColor = backgroundColor.cgColor
    }

    override func updateTrackingAreas() {
        updateCursorTrackingArea()
    }

    override func mouseEntered(with event: NSEvent) {
        guard !ignoresMouseEvents
            else { return }

        super.mouseEntered(with: event)
        cursorTrackingHandler?(self, true)
    }

    override func mouseExited(with event: NSEvent) {
        guard !ignoresMouseEvents
            else { return }

        super.mouseExited(with: event)
        cursorTrackingHandler?(self, false)
    }
}
