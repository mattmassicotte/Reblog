// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "Reblog",
	products: [
		.library(name: "Reblog", targets: ["Reblog"]),
	],
	targets: [
		.target(
			name: "Reblog"),
		.testTarget(
			name: "ReblogTests",
			dependencies: ["Reblog"]
		),
	]
)
