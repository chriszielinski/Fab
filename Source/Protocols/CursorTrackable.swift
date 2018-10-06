//
//  CursorTrackable.swift
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

protocol CursorTrackable: class {
    /// A handler that is called whenever the cursor has interacted with the tracking rectangle.
    ///
    /// Passes in `true` when the cursor entered the tracking rectangle, and `false` when exited.
    var cursorTrackingHandler: ((Bool) -> Void)? { get }
    var trackingAreaTag: NSView.TrackingRectTag? { get set }

    func updateCursorTrackingArea()
}

extension CursorTrackable where Self: NSView {
    func updateCursorTrackingArea() {
        if let trackingAreaTag = trackingAreaTag {
            removeTrackingRect(trackingAreaTag)
        }

        trackingAreaTag = addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
}
