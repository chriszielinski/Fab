//
//  ColoredButton.swift
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

open class ColoredButton: NSButton {

    public var backgroundColor: NSColor?
    @available(macOS, obsoleted: 11.0)
    public var wantsVibrancy: Bool = true

    open override var allowsVibrancy: Bool {
        if #available(macOSApplicationExtension 11.0, *) {
            return super.allowsVibrancy
        } else {
            return wantsVibrancy
        }
    }

    open override var wantsUpdateLayer: Bool {
        return true
    }

    public init(frame frameRect: NSRect = .zero, backgroundColor: NSColor?) {
        super.init(frame: frameRect)

        self.backgroundColor = backgroundColor
        wantsLayer = true
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func addSubview(_ view: NSView) {
        if #available(macOSApplicationExtension 11.0, *) {
        } else if !wantsVibrancy, let textField = view as? NSTextField {
            /// This monster is necessary to get non-vibrancy in a borderless button... really?
            let newTextField = NonVibrantTextField(labelWithString: textField.stringValue)

            newTextField.frame = bounds
            newTextField.autoresizingMask = [.width, .height]
            newTextField.cell = textField.cell

            super.addSubview(newTextField)

            return
        }

        super.addSubview(view)
    }

    override open func updateLayer() {
        setAnchorPointToCenter()
        layer!.backgroundColor = backgroundColor?.cgColor
    }
}
