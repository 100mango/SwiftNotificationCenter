
<p align="center"> <img src="logo.png" />
<br>

 ![](http://img.shields.io/badge/Swift-5.0-blue.svg)



A Protocol-Oriented NotificationCenter which is type safe, thread safe and with memory safety.

- Type Safe

	No more `userInfo` dictionary and Downcasting, just deliver the concrete type value to the observer.
	
- Thread Safe

	You can `register`, `notify`, `unregister` in any thread without crash and data corruption.
	
- Memory Safety

	 `SwiftNotificationCenter` store the observer as a zeroing-weak reference. No crash and no need to `unregister` manually.
		
It's simple, safe, lightweight and easy to use for `one-to-many` communication.


## Usage

Define protocol and observer:

~~~swift
protocol Update {
    func updateTitle(title: String)
}

extension ViewController: Update {
  func updateTitle(title: String) {
  		self.titleLabel.text = title
  }
}
let vc = ViewController()
~~~

Register:

~~~swift
Broadcaster.register(Update.self, observer: vc)
~~~

Broadcast:

~~~swift
Broadcaster.notify(Update.self) {
    $0.updateTitle("new title")
}
~~~

Unregister:

~~~swift
Broadcaster.unregister(Update.self, observer: self)
~~~

<br>

Compare with `NSNotificationCenter` :

For example, handle `UIKeyboardWillShowNotification`

~~~swift
@objc func handleKeyboardNotification(notification: NSNotification) {
    guard notification.name == NSNotification.Name.UIKeyboardWillShow
        else { return }
    
    guard let beginFrame = (notification
        .userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
    
    guard let endFrame = (notification
        .userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
    // use beginFrame, endFrame
}
~~~

`SwiftNotificationCenter` way:

~~~swift
/*
If you want to observe the system built in notifications like this.
You can declare a protocol and the relevant method, and use a singleton as a mediator to observe system's notification, then notify our observers.
Please check the refactor example in SwiftNotificationCenterExample Project.
*/
func UIKeyboardWillShow(beginFrame: CGRect, endFrame: CGRect) {
}
~~~

## Installation

### Swift Package Manager

Add `https://github.com/100mango/SwiftNotificationCenter.git` as a package
dependency in Xcode, choose version **1.1.0 or later**, and add the
`SwiftNotificationCenter` product to your target. Version 1.1.0 is the first
release with Swift Package Manager support; 1.0.5 and earlier do not include
`Package.swift`.

In another package's `Package.swift`, use:

~~~swift
dependencies: [
    .package(
        url: "https://github.com/100mango/SwiftNotificationCenter.git",
        from: "1.1.0"
    )
],
targets: [
    .target(name: "YourTarget", dependencies: ["SwiftNotificationCenter"])
]
~~~

Then `import SwiftNotificationCenter` in your Swift files. For local development,
add the checkout as a local package in Xcode or use
`.package(path: "../SwiftNotificationCenter")`.

The manifest uses Swift tools 5.0 and Swift 5 language mode, and retains the
library's declared iOS 8.0 and macOS 10.9 deployment targets. The installed
Xcode/Swift toolchain may require a newer deployment target. CocoaPods and
Carthage installation remain unchanged.

### CocoaPods

~~~
pod 'SwiftNotificationCenter'
~~~

### Carthage

~~~
github "100mango/SwiftNotificationCenter"
~~~

### Manually

Just copy source files in the SwiftNotificationCenter folder into your project.

## Testing

Run the package tests from the repository root with a current Swift toolchain:

~~~sh
swift build
swift test
swift test --configuration release
~~~

The package builds the library sources directly and reuses the Xcode test
suite. It does not include the UIKit example application, umbrella header, or
Xcode Info.plist files. The Foundation-only library can also be tested on Linux;
Apple-platform builds still require an appropriate Xcode SDK.


## License

`SwiftNotificationCenter` is under the MIT license.
