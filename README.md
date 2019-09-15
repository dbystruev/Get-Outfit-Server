# Get Outfit Server

## Run for release
```
swift package clean
swift build -c release
swift run -c release
```

## Run to debug
```
switch package clean
swift build
swift run
```

## Use Xcode
```
swift package generate-xcodeproj
open Server.xcodeproj
```
