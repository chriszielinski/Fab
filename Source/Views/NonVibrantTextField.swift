//
//  NonVibrantTextField.swift
//  Fab
//
//  Created by Chris Zielinski on 8/11/21.
//  Copyright © 2021 Big Z Labs. All rights reserved.
//

import Cocoa

class NonVibrantTextField: NSTextField {

    override var allowsVibrancy: Bool {
        return false
    }

}
