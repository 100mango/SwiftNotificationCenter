#!/usr/bin/env bash
set -euo pipefail

version="${1:?Usage: verify-swiftpm-consumer.sh VERSION}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Expected a semantic version such as 1.1.0" >&2
  exit 1
fi

consumer="$(mktemp -d)"
trap 'rm -rf "$consumer"' EXIT
mkdir -p "$consumer/Sources/Consumer" "$consumer/Tests/ConsumerTests"

# PACKAGE_PATH is only for checking this consumer against a local checkout.
# Without it, resolve the exact public release rather than a moving branch.
python3 - "$consumer/Package.swift" "$version" "${PACKAGE_PATH:-}" <<'PY'
import json
import pathlib
import sys

manifest, version, local_path = sys.argv[1:]
dependency = (
    '.package(path: ' + json.dumps(local_path, ensure_ascii=False) + ')'
    if local_path else
    '.package(url: "https://github.com/100mango/SwiftNotificationCenter.git", .exact("' + version + '"))'
)
pathlib.Path(manifest).write_text('''// swift-tools-version:5.0
import PackageDescription
let package = Package(
    name: "Consumer",
    dependencies: [''' + dependency + '''],
    targets: [
        .target(name: "Consumer", dependencies: ["SwiftNotificationCenter"]),
        .testTarget(name: "ConsumerTests", dependencies: ["Consumer", "SwiftNotificationCenter"])
    ],
    swiftLanguageVersions: [.v5]
)
''')
PY

cat > "$consumer/Sources/Consumer/Consumer.swift" <<'SWIFT'
import SwiftNotificationCenter

public protocol MessageObserver: AnyObject {
    func receive(_ message: String)
}

public func broadcast(_ message: String) {
    Broadcaster.notify(MessageObserver.self) { $0.receive(message) }
}
SWIFT

cat > "$consumer/Tests/ConsumerTests/ConsumerTests.swift" <<'SWIFT'
import Consumer
import SwiftNotificationCenter
import XCTest

final class Observer: MessageObserver {
    var messages = [String]()
    func receive(_ message: String) { messages.append(message) }
}

final class WeakReference {
    weak var value: Observer?
    init(_ value: Observer) { self.value = value }
}

final class ConsumerTests: XCTestCase {
    override func tearDown() {
        Broadcaster.unregister(MessageObserver.self)
        Broadcaster.notify(MessageObserver.self) { _ in }
        super.tearDown()
    }

    func testPublicProductDeliversTypedMessages() {
        let observer = Observer()
        Broadcaster.register(MessageObserver.self, observer: observer)
        broadcast("from the external consumer")
        XCTAssertEqual(observer.messages, ["from the external consumer"])
    }

    func testUnregisterStopsDelivery() {
        let observer = Observer()
        Broadcaster.register(MessageObserver.self, observer: observer)
        Broadcaster.unregister(MessageObserver.self, observer: observer)
        broadcast("must not arrive")
        XCTAssertTrue(observer.messages.isEmpty)
    }

    func testPublicRegistrationDoesNotRetainObservers() {
        var observer: Observer? = Observer()
        let reference = WeakReference(observer!)
        Broadcaster.register(MessageObserver.self, observer: observer!)
        broadcast("drain registration")
        observer = nil
        XCTAssertNil(reference.value)
        Broadcaster.notify(MessageObserver.self) { _ in
            XCTFail("A released observer must not be delivered to")
        }
    }
}
SWIFT

swift package --package-path "$consumer" resolve
if [[ -z "${PACKAGE_PATH:-}" ]]; then
  python3 - "$consumer/Package.resolved" "$version" "${EXPECTED_REVISION:-}" <<'PY'
import json
import pathlib
import sys

path, expected_version, expected_revision = sys.argv[1:]
resolved = json.loads(pathlib.Path(path).read_text())
pins = resolved.get('pins', resolved.get('object', {}).get('pins', []))
assert len(pins) == 1, pins
state = pins[0]['state']
assert state['version'] == expected_version, state
if expected_revision:
    assert state['revision'] == expected_revision, state
print('Resolved SwiftNotificationCenter ' + state['version'] + ' at ' + state['revision'])
PY
fi
swift build --package-path "$consumer" --jobs 2
swift test --package-path "$consumer" --jobs 2
swift test --package-path "$consumer" --configuration release --jobs 2
