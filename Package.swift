// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTestKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "SwiftTestKit", targets: ["SwiftTestKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pawelini1/SwiftHttpShell.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target( name: "SwiftTestKit", dependencies: [
            .product(name: "SwiftHttpShellClient", package: "SwiftHttpShell")
        ])
    ]
)
