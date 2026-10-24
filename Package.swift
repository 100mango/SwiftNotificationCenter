// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftNotificationCenter",
    platforms: [
        .iOS("8.0"),
        .macOS("10.9")
    ],
    products: [
        .library(name: "SwiftNotificationCenter", targets: ["SwiftNotificationCenter"])
    ],
    targets: [
        .target(
            name: "SwiftNotificationCenter",
            path: "SwiftNotificationCenter",
            exclude: ["Info.plist", "SwiftNotificationCenter.h"]
        ),
        .testTarget(
            name: "SwiftNotificationCenterTests",
            dependencies: ["SwiftNotificationCenter"],
            path: "SwiftNotificationCenterTests",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
