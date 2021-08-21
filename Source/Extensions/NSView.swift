//
//  NSView.swift
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

extension NSView {
    var center: NSPoint {
        get {
            let origin = frame.origin
            let size = frame.size
            var point = NSPoint(x: origin.x + (size.width / 2),
                                y: origin.y + (size.height / 2))

            guard let superview = superview, !superview.isFlipped
                // Not flipped, so return point.
                else { return point }

            // Flipped, so have to adjust.
            point.y = superview.frame.height - point.y
            return point
        }
        set {
            var newOrigin = newValue
            let size = frame.size
            newOrigin.x -= size.width / 2
            newOrigin.y -= size.height / 2
            setFrameOrigin(newOrigin)
        }
    }

    func setAnchorPointToCenter() {
        setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
    }

    func animateScaling(to scale: CGFloat) {
        guard let layer = layer
        else { return }

        setAnchorPointToCenter()

        NSAnimationContext.runAnimationGroup { (context) in
            context.duration = 0.2
            context.allowsImplicitAnimation = true

            layer.setAffineTransform(scale == 1 ? .identity : layer.affineTransform().scaledBy(x: scale, y: scale))
        }
    }
}

//
//  NSView+ChangeAnchorPointWithoutMakingTheLayerJump.swift
//
//  Setting .anchorPoint on a layer makes the layer jump which is most
//  likely not what you want. This extension fixes that. Useful for Core Animation.
//
//  Usage: (e.g., to set the anchor point to the centre)
//
//  myView.setAnchorPoint(CGPointMake(0.5, 0.5))
//
//  Created by Aral Balkan on 18/07/2015.
//  Copyright (c) 2015 Ind.ie. Released under the MIT License.
//

extension NSView {
    //
    // Converted to Swift + NSView from:
    // http://stackoverflow.com/a/10700737
    //
    // New: Converted to Swift 4+
    func setAnchorPoint(anchorPoint: CGPoint) {
        if let layer = self.layer {
            var newPoint = CGPoint(x: bounds.size.width * anchorPoint.x,
                                   y: bounds.size.height * anchorPoint.y)
            var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x,
                                   y: bounds.size.height * layer.anchorPoint.y)

            newPoint = newPoint.applying(layer.affineTransform())
            oldPoint = oldPoint.applying(layer.affineTransform())

            var position = layer.position

            position.x -= oldPoint.x
            position.x += newPoint.x

            position.y -= oldPoint.y
            position.y += newPoint.y

            layer.position = position
            layer.anchorPoint = anchorPoint
        }
    }
}
