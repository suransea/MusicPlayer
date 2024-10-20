// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "MusicPlayer",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "MusicPlayer", targets: ["MusicPlayer"]),
        .library(name: "LXMusicPlayer", targets: ["LXMusicPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ddddxxx/SpotifyiOSWrapper", from: "1.2.2"),
        .package(url: "https://github.com/suransea/mpris-swift", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MusicPlayer",
            dependencies: [
                .product(name: "MPRIS", package: "mpris-swift"),
                .product(
                    name: "SpotifyiOSWrapper", package: "SpotifyiOSWrapper",
                    condition: .when(platforms: [.iOS])),
                .target(name: "LXMusicPlayer", condition: .when(platforms: [.macOS])),
                .target(name: "MediaRemotePrivate", condition: .when(platforms: [.macOS, .iOS])),
            ],
            cSettings: [
                .define("TARGET_OS_MAC", to: "1", .when(platforms: [.macOS, .iOS])),
                .define("TARGET_OS_IPHONE", to: "1", .when(platforms: [.iOS])),
            ]),
        .target(
            name: "LXMusicPlayer",
            cSettings: [
                .define("TARGET_OS_MAC", to: "1", .when(platforms: [.macOS, .iOS])),
                .define("TARGET_OS_IPHONE", to: "1", .when(platforms: [.iOS])),
                .headerSearchPath("private"),
                .headerSearchPath("BridgingHeader"),
            ]),
        .target(
            name: "MediaRemotePrivate",
            cSettings: [
                .define("TARGET_OS_MAC", to: "1", .when(platforms: [.macOS, .iOS])),
                .define("TARGET_OS_IPHONE", to: "1", .when(platforms: [.iOS])),
            ]),
    ]
)
