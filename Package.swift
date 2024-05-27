// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var fetchingView: Target.Dependency {
        .product(name: "FetchingView", package: "swiftui-fetching-view")
    }
}

let package = Package(
    name: "ImageDownloader",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ImageDownloader",
            targets: ["ImageDownloader"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ratnesh-jain/swiftui-fetching-view.git", .upToNextMajor(from: "0.1.0")),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ImageDownloader",
            dependencies: [.fetchingView]
        ),
    ]
)
