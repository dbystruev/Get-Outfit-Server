# Get Outfit Server

Server for [Get Outfit](https://getoutfit.ru)

* Run Get Outfit Server in Docker from Swift image
  ```bash
  docker run -p80:8888 -it --name GetOutfit -w/GetOutfit swift bash
  mkdir -p $HOME/Documents/XML
  git clone https://github.com/dbystruev/Get-Outfit-Server.git .
  apt update && apt -y upgrade
  apt -y install openssl libssl-dev libmysqlclient-dev libcurl4-openssl-dev vim
  vi Sources/Server/Models/Shop+Data.swift # fill with your Admitad data (see below)
  swift build -c release
  exit
  ```
  
* Create getoutfit image
  ```bash
  docker commit GetOutfit getoutfit
  docker rm GetOutfit
  ```
  
* Run new Get Outfit Server in Docker from getoutfit image
  ```bash
  docker run --name GetOutfit -p80:8888 -d -w/GetOutfit getoutfit swift run -c release
  ```

## Format of Sources/Server/Models/Shop+Data.swift
```swift
extension Shop {
    static var all: [Shop] {
        return [
            Shop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                last_import: "2000.01.01.00.00",
                name: "First Shop Name",
                remotePath: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            Shop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                last_import: "2000.01.01.00.00",
                name: "Second Shop Name",
                remotePath: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            // ...
        ]
    }
}
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
  - [?duration=true](http://server.getoutfit.ru/offers?duration=true)
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
