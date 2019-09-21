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
  - [?id=1](http://server.getoutfit.ru/categories?id=1)
  - [?name=text](http://server.getoutfit.ru/categories?name=text)
  - [?parentId=1](http://server.getoutfit.ru/categories?parentId=1)
  - [?count=true](http://server.getoutfit.ru/categories?count=true)
- [/currencies](http://server.getoutfit.ru/currencies)
  - [?count=true](http://server.getoutfit.ru/currencies?count=true)
- [/date](http://server.getoutfit.ru/date)
- [/images](http://server.getoutfit.ru/images)
  - [?count=true](http://server.getoutfit.ru/images?count=true)
- [/modified_times](http://server.getoutfit.ru/modified_times)
- [/offers](http://server.getoutfit.ru/offers)
  - [?available=true](http://server.getoutfit.ru/offers?available=true) (set by default)
  - [?count=true](http://server.getoutfit.ru/offers?count=true)
  - [?deleted=true](http://server.getoutfit.ru/offers?deleted=true)
  - [?id=text](http://server.getoutfit.ru/offers?id=text)
  - [?categoryId=1](http://server.getoutfit.ru/offers?categoryId=1)
  - [?currencyId=RUB](http://server.getoutfit.ru/offers?currencyId=RUB)
  - [?description=text](http://server.getoutfit.ru/offers?description=text)
  - [?manufacturer_warranty=true](http://server.getoutfit.ru/offers?manufacturer_warranty=true)
  - [?model=text](http://server.getoutfit.ru/offers?model=text)
  - [?modified_after=1569058481](http://server.getoutfit.ru/offers?modified_after=1569058481)
  - [?modified_before=1569058481](http://server.getoutfit.ru/offers?modified_before=1569058481)
  - [?modified_time=1569058481](http://server.getoutfit.ru/offers?modified_time=1569058481)
  - [?name=text](http://server.getoutfit.ru/offers?name=text)
  - [?oldprice=999](http://server.getoutfit.ru/offers?oldprice=999)
  - [?oldprice_above=999](http://server.getoutfit.ru/offers?oldprice_above=999)
  - [?oldprice_below=999](http://server.getoutfit.ru/offers?oldprice_below=999)
  - [?picture=text](http://server.getoutfit.ru/offers?picture=text)
  - [?price=999](http://server.getoutfit.ru/offers?price=999)
  - [?price_above=999](http://server.getoutfit.ru/offers?price_above=999)
  - [?price_below=999](http://server.getoutfit.ru/offers?price_below=999)
  - [?sales_notes=text](http://server.getoutfit.ru/offers?sales_notes=text)
  - [?typePrefix=text](http://server.getoutfit.ru/offers?typePrefix=text)
  - [?url=text](http://server.getoutfit.ru/offers?url=text)
  - [?vendor=text](http://server.getoutfit.ru/offers?vendor=text)
  - [?vendorCode=text](http://server.getoutfit.ru/offers?vendorCode=text)
- [/params](http://server.getoutfit.ru/params)
  - [?count=true](http://server.getoutfit.ru/params?count=true)
- [/prices](http://server.getoutfit.ru/prices)
- [/update](http://server.getoutfit.ru/update)

Categories and offers can be filtered by its fields.

## HTML Routes
- [/](http://server.getoutfit.ru)
- [/stylist](http://server.getoutfit.ru/stylist?subid=app)

Stylist should be given a subid parameter.
