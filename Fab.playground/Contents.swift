//: `Fab` is a **F**loating **A**ction **B**utton inspired by Material Design.

import AppKit
import PlaygroundSupport
/// Note: Must use within the Xcode project, AND must first build the framework (⌘B).
import Fab

let imageView = NSImageView(frame: NSRect(origin: .zero, size: CGSize(width: 640, height: 360)))
imageView.image = NSImage(named: "mojave-day")!
PlaygroundPage.current.liveView = imageView

func selected(item: FabItem, with index: Int) {
    print("Selected item \(index): \"\(item.text)\"")
}

// Create an action item using an image.
// Note: For the item action, we are passing in a complying function directly as an argument.
let twitterItem = FabItem(label: "Twitter",
                                   image: NSImage(named: "twitter_icon")!,
                                   action: selected)

// These attributes will be used for the "+" item. This is necessary to center the string in the button.
let plusIconAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.controlContentFont(ofSize: 25),
    .baselineOffset: 2,
    .kern: -1
]
let plusIcon = NSAttributedString(string: "+", attributes: plusIconAttributes)
// Create an action item using an attributed string.
// Note: Here we are using a trailing closure for the item action.
let addItem = FabItem(label: "Add something", buttonIcon: plusIcon) { (item, itemIndex) in
    selected(item: item, with: itemIndex)
}

// Create an action item using an emoji.
// This convenience initializer applies some default formatting that should satisfy most emojis.
let emojiItem = FabItem(label: "Emoji", emoji: "👍")
// Or you can assign the item action after initializing the item.
emojiItem.action = { (item, itemIndex) in
    selected(item: item, with: itemIndex)
}

// Create a translucent, vibrant Fab.
let fab = Fab(attachedTo: imageView, kind: .visualEffect, items: [twitterItem, addItem, emojiItem])
fab.keyEquivalent = FabKeyEquivalent(keyEquivalent: "f", modifierMask: [.command])

// Uncomment to create a Fab with a solid background instead.
//        fab = Fab(attachedToView: view, kind: .colored, items: [twitterItem, addItem, emojiItem])
//        fab.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)

fab.backgroundColorSelected = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

