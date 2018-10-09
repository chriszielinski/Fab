//
//  ViewController.swift
//  Fab. Demo
//
//  Created by Chris Zielinski on 10/1/18.
//  Copyright © 2018 Big Z Labs. All rights reserved.
//

import Cocoa
import Fab

class ViewController: NSViewController {

    var fab: Fab!

    func presentAlert(for item: FabItem, with index: Int) {
        let alert = NSAlert()
        alert.messageText = "Pressed item \(index): \"\(item.text)\""

        if let window = view.window {
            alert.beginSheetModal(for: window)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a Fab item using an image.
        // Note: For the item action, we are passing in a complying function directly as an argument.
        let twitterItem = FabItem(label: "Twitter",
                                  image: NSImage(named: "twitter_icon")!,
                                  action: presentAlert)

        // These attributes will be used for the "+" item. This is necessary to center the string in the button.
        let plusIconAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.controlContentFont(ofSize: 25),
            .baselineOffset: 2,
            .kern: -1
        ]
        let plusIcon = NSAttributedString(string: "+", attributes: plusIconAttributes)
        // Create a Fab item using an attributed string.
        // Note: Here we are using a trailing closure for the item action.
        let addItem = FabItem(label: "Add something", buttonIcon: plusIcon) { (item, itemIndex) in
            self.presentAlert(for: item, with: itemIndex)
        }

        // Create a Fab item using an emoji.
        // This convenience initializer applies some default formatting that should satisfy most emojis.
        let emojiItem = FabItem(label: "Emoji", emoji: "👍")
        // Or you can assign the item action after initializing the item.
        emojiItem.action = { (item, itemIndex) in
            self.presentAlert(for: item, with: itemIndex)
        }

        // Create a translucent, vibrant Fab.
        fab = Fab(attachedTo: view, kind: .visualEffect, items: [twitterItem, addItem, emojiItem])
        fab.keyEquivalent = FabKeyEquivalent(keyEquivalent: "f", modifierMask: [.command])

        // Uncomment to create a Fab with a solid background instead.
//        fab = Fab(attachedToView: view, kind: .colored, items: [twitterItem, addItem, emojiItem])
//        fab.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)

        fab.backgroundColorSelected = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    }
}
