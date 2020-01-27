all:
	Carthage update --no-use-binaries --platform iOS	
	cd Carthage/Checkouts/ReactorKit
	swift package generate-xcodeproj
	cd ../../..
	carthage build --platform iOS ReactorKit