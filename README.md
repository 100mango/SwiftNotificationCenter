# SwiftNotificationCenter

A Protocol-Oriented NotificationCenter which is type safe, thread safe and with memory safety.

- Type Safe

	No more `userInfo` dictionary and Downcasting, just deliver the concrete type value to the observer.
	
- Thread Safe

	You can `register`, `notify`, `unregister` in any thread without crash and data corruption.
	
- Memory Safety

	 SwiftNotificationCenter store the observer as a zeroing-weak reference. No crash and no need to `unregister` manually.
		
It's simple, safe, lghtweight and easy to use for `one-to-many` communication.


##Usage

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
NotificationCenter.register(Update.self, observer: vc)
~~~

Broadcast:

~~~swift
NotificationCenter.notify(Update.self) {
    $0.updateTitle("new title")
}
~~~

Unregister:

~~~swift
NotificationCenter.unregister(Update.self, observer: self)
~~~

##Installation

CocoaPods:

~~~
pod 'SwiftNotificationCenter'
~~~

Manually: 

Just copy source files in the SwiftNotificationCenter folder into your project.


## License

`SwiftNotificationCenter` is under the MIT license.