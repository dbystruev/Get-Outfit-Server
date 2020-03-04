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
  - [?name=обувь](http://server.getoutfit.ru/categories?name=обувь)
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
  - [?id=AD093FUALPE7](http://server.getoutfit.ru/offers?id=AD093FUALPE7)
  - [?id=AD093FUALPE7&id=AN057AUBZ383](http://server.getoutfit.ru/offers?id=AD093FUALPE7&id2=AN057AUBZ383)
  - [?categoryId=1017](http://server.getoutfit.ru/offers?categoryId=1017)
  - [?currencyId=RUB](http://server.getoutfit.ru/offers?currencyId=RUB)
  - [?description=футболка](http://server.getoutfit.ru/offers?description=футболка)
  - [?manufacturer_warranty=true](http://server.getoutfit.ru/offers?manufacturer_warranty=true)
  - [?model=adidas](http://server.getoutfit.ru/offers?model=adidas)
  - [?modified_after=1569058481](http://server.getoutfit.ru/offers?modified_after=1569058481)
  - [?modified_before=1569058481](http://server.getoutfit.ru/offers?modified_before=1569058481)
  - [?modified_time=1569058481](http://server.getoutfit.ru/offers?modified_time=1569058481)
  - [?name=кроссовки](http://server.getoutfit.ru/offers?name=кроссовки)
  - [?oldprice=999](http://server.getoutfit.ru/offers?oldprice=999)
  - [?oldprice_above=999](http://server.getoutfit.ru/offers?oldprice_above=999)
  - [?oldprice_below=999](http://server.getoutfit.ru/offers?oldprice_below=999)
  - [?picture=600x866](http://server.getoutfit.ru/offers?picture=600x866)
  - [?price=999](http://server.getoutfit.ru/offers?price=999)
  - [?price_above=999](http://server.getoutfit.ru/offers?price_above=999)
  - [?price_below=999](http://server.getoutfit.ru/offers?price_below=999)
  - [?sales_notes=скидки](http://server.getoutfit.ru/offers?sales_notes=скидки)
  - [?typePrefix=очки](http://server.getoutfit.ru/offers?typePrefix=очки)
  - [?url=armani](http://server.getoutfit.ru/offers?url=armani)
  - [?vendor=armani](http://server.getoutfit.ru/offers?vendor=armani)
  - [?vendorCode=0AX4026S](http://server.getoutfit.ru/offers?vendorCode=0AX4026S)
- [/params](http://server.getoutfit.ru/params)
  - [?count=true](http://server.getoutfit.ru/params?count=true)
- [/prices](http://server.getoutfit.ru/prices)
- [/update](http://server.getoutfit.ru/update)

Categories and offers can be filtered by its fields.

## HTML Routes
- [/](http://server.getoutfit.ru)
- [/stylist](http://server.getoutfit.ru/stylist?subid=app)

Stylist should be given a subid parameter.
