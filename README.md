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

## JSON Routes
- [/categories](http://server.getoutfit.ru/categories)
- [/currencies](http://server.getoutfit.ru/currencies)
- [/offers](http://server.getoutfit.ru/offers)
- [/params](http://server.getoutfit.ru/params)

Categories and offers can be filtered by its fields.

## HTML Routes
- [/](http://server.getoutfit.ru)
- [/stylist](http://server.getoutfit.ru/stylist)

Stylist should be given a subid parameter.
