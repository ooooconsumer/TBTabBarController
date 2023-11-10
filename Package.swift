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
                "TBTabBarControllerFramework",
            ]
        )
    ],
    targets: [
        .target(
            name: "TBTabBarControllerFramework",
            path: "TBTabBarControllerFramework/Source",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Private"),
                .headerSearchPath("Private/Categories/Foundation"),
                .headerSearchPath("Private/Categories/UIKit"),
            ]
        )
    ]
)
