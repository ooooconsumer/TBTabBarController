// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "TBTabBarController",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "TBTabBarController",
            targets: [
                "TBTabBarController",
            ]
        )
    ],
    targets: [
        .target(
            name: "TBTabBarController",
            path: "TBTabBarController/Source",
            publicHeadersPath: "Include",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Source"),
                .headerSearchPath("Source/Private"),
                .headerSearchPath("Source/Categories/Foundation"),
                .headerSearchPath("Source/Categories/UIKit"),
            ]
        )
    ]
)

