Fab. 🛍️
----
 
<p align="center">
	<a href="http://cocoadocs.org/docsets/Fab" style="text-decoration:none">
		<img alt="Platform" src ="https://img.shields.io/cocoapods/p/Fab.svg?style=flat"/>
	</a>
	<a href="http://cocoadocs.org/docsets/Fab/" style="text-decoration:none">
		<img alt="Pod Version" src ="https://img.shields.io/cocoapods/v/Fab.svg?style=flat"/>
	</a>
	<a href="https://github.com/Carthage/Carthage" style="text-decoration:none">
		<img alt="Carthage compatible" src ="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/>
	</a>
	<a href="https://developer.apple.com/swift" style="text-decoration:none">
		<img alt="Swift Version" src ="https://img.shields.io/badge/language-swift%204.2-brightgreen.svg"/>
	</a>
	<a href="https://github.com/chriszielinski/Fab/blob/master/LICENSE" style="text-decoration:none">
		<img alt="GitHub license" src ="https://img.shields.io/badge/license-MIT-blue.svg"/>
	</a>
	<br>
	<img src ="https://raw.githubusercontent.com/chriszielinski/Fab/master/readme-assets/Fab.gif"/>
	<br>
	<br>
	A <b>F</b>loating <b>A</b>ction <b>B</b>utton for macOS. Inspired by Material Design, and written in Swift.
	<br>
	Based on Lourenço Marinho's <a href="https://github.com/lourenco-marinho/ActionButton"><code>ActionButton</code></a> for UIKit.
	<br>
</p>

----

### Features

- [x] Dark Mode	

	<img width="203" height="250" src ="https://raw.githubusercontent.com/chriszielinski/Fab/master/readme-assets/light-dark-mode.png"/>
- [x] + more.


Installation
----

`Fab` is available for installation using CocoaPods or Carthage.

### [CocoaPods](http://cocoapods.org/)

```ruby
pod "Fab"
```

### [Carthage](https://github.com/Carthage/Carthage)

```ruby
github "chriszielinski/Fab"
```


Requirements
----

- macOS 10.12+


Usage
----

#### Create `FabItem`s
```swift
let shareItem = FabItem(label: "Share", shareImage)
shareItem.action = { item in
	print("Selected \"Share\"")
}

let emailItem = FabItem(label: "Email", emoji: "✉️") { item in
	print("Selected \"Email\"")
}
```

#### Create `Fab` with items.
```swift
let fab = Fab(attachedTo: aView, items: [shareItem, emailItem])
```


Documentation
----

There are a lot of properties you can dabble with. You can check out the docs [here](http://chriszielinski.github.io/Fab/). Documentation is generated with [jazzy](https://github.com/realm/jazzy) and hosted on [GitHub-Pages](https://pages.github.com).

Try Me
----

Includes a Playground and Demo.app.


// ToDo:
----

- [ ] Tests.

// CouldDo:
----

- [ ] Use CALayer.
- [ ] Internal refactoring.


Acknowledgements
----

* Based on Lourenço Marinho's [`ActionButton`](https://github.com/lourenco-marinho/ActionButton) for UIKit.


Contributors
----

- [Chris Zielinski](https://github.com/chriszielinski) — Original author.


License
----

Fab is released under the MIT license. See LICENSE for details.
