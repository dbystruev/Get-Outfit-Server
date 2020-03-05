# Get Outfit Server

Server for [Get Outfit](https://getoutfit.ru)

* Install Get Outfit Server in Docker from Swift image
  ```bash
  docker run -p80:8888 -it --name GetOutfit -w/GetOutfit swift bash
  mkdir -p $HOME/Documents/XML
  git clone https://github.com/dbystruev/Get-Outfit-Server.git .
  apt update && apt -y upgrade
  apt -y install openssl libssl-dev libmysqlclient-dev libcurl4-openssl-dev vim
  mv Sources/Server/Models/RemoteShop+Data+sample.swift Sources/Server/Models/RemoteShop+Data.swift
  vi Sources/Server/Models/RemoteShop+Data.swift # fill with your Admitad data (see below)
  exit
  ```

* Create build image and load initial data
    ```docker commit GetOutfit getoutfit_build
    docker rm GetOutfit
    docker run --name GetOutfit -p80:8888 -d -w/GetOutfit getoutfit_build swift run -c release
    docker logs -f GetOutfit
    # after the server has been compiled & started press Ctrl-C on Linux or Cmd-. on macOS
    curl localhost/update
    docker exec GetOutfit mv /root/Documents/XML/update.xml /root/Documents/XML/full.xml
    docker stop GetOutfit
    
    ```
  
* Create release image
  ```bash
  docker commit GetOutfit getoutfit_release
  docker rm GetOutfit
  docker rmi getoutfit_build
  ```

* Save docker image on development server and copy it to production server
  ```bash
  docker image save -o getoutfit.tar getoutfit_release
  docker rmi getoutfit_release
  scp getoutfit.tar production-server:\~/
  rm getoutfit.tar
  ```
  
* Load and run docker image on production server
```bash
 docker image load -i getoutfit.tar
 rm getoutfit.tar
 docker stop GetOutfit && docker rm GetOutfit && docker rmi getoutfit && docker tag getoutfit_release getoutfit && docker run --name GetOutfit -p80:8888 -d -w/GetOutfit getoutfit swift run -c release
 docker rmi getoutfit_release
  ```

## Format of Sources/Server/Models/RemoteShop+Data.swift
```swift
extension RemoteShop {
    static var all: [RemoteShop] {
        return [
            RemoteShop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                format: "xml",
                last_import: "2000.01.01.00.00",
                name: "First Shop Name",
                path: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            RemoteShop(
                code: "Get from Admitad",
                currency: "RUB",
                feed_id: "Get from Admitad",
                format: "xml",
                last_import: "2000.01.01.00.00",
                name: "Second Shop Name",
                path: "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/",
                template: "Get from Admitad",
                user: "Get from Admitad"
            ),
            // ...
        ]
    }
}
```

## JSON Routes
- [/categories](http://server.getoutfit.ru/categories) Return the list of categories
  - [?from=100](http://server.getoutfit.ru/categories?from=100) Skip the given number of categories (for pagination)
  - [?id=1](http://server.getoutfit.ru/categories?id=1) Return a category with a given id
  - [?limit=24](http://server.getoutfit.ru/categories?limit=24) Limit the total number of categories returned (for pagination).  24 is the default
  - [?name=обувь](http://server.getoutfit.ru/categories?name=обувь) Return the list of categories with given word in category name
  - [?parentId=1](http://server.getoutfit.ru/categories?parentId=1) Return a category whose parent has a given parent ID
  - [?count=true](http://server.getoutfit.ru/categories?count=true) Return the number of categories instead of their list
- [/currencies](http://server.getoutfit.ru/currencies) Return the list of currencies
  - [?count=true](http://server.getoutfit.ru/currencies?count=true) Return the number of currencies instead of their list
- [/date](http://server.getoutfit.ru/date) Return the last date the database was updated
- [/images](http://server.getoutfit.ru/images) Return the list of all images sorted alphabetically
  - [?count=true](http://server.getoutfit.ru/images?count=true) Return the number of images instead of their list
  - [?duration=true](http://server.getoutfit.ru/images?duration=true) Return the time spent on request instead of images list
  - [?format=html](http://server.getoutfit.ru/images?format=html) Display the images in HTML format instead of JSON
  - [?from=100](http://server.getoutfit.ru/images?from=100) Skip the given number of images (for pagination)
  - [?limit=24](http://server.getoutfit.ru/images?limit=24) Limit the total number of images returned (for pagination).  24 is the default
- [/modified_times](http://server.getoutfit.ru/modified_times) Return the earliest and latest offer modification times (as Unix timestamps)
- [/offers](http://server.getoutfit.ru/offers) Return the list of all offers/goods
  - [?available=true](http://server.getoutfit.ru/offers?available=true) Filter by available offers only (set by default)
  - [?count=true](http://server.getoutfit.ru/offers?count=true) Return the number of offers instead of their list
  - [?deleted=true](http://server.getoutfit.ru/offers?deleted=true) Filter by deleted offers only
  - [?duration=true](http://server.getoutfit.ru/offers?duration=true) Return the time spent on request instead of offers list
  - [?id=AD093FUALPE7](http://server.getoutfit.ru/offers?id=AD093FUALPE7) Return an offer with a given ID
  - [?id=AD093FUALPE7&id=AN057AUBZ383](http://server.getoutfit.ru/offers?id=AD093FUALPE7&id=AN057AUBZ383) Return the list of offers with given IDs
  - [?categoryId=1017](http://server.getoutfit.ru/offers?categoryId=1017) Return the list of offers in a given category
  - [?currencyId=RUB](http://server.getoutfit.ru/offers?currencyId=RUB) Return the list of offers with price in a given currency
  - [?description=футболка](http://server.getoutfit.ru/offers?description=футболка) Filter the list of offers by a given word in offer's description
  - [?from=1000](http://server.getoutfit.ru/offers?from=1000) Skip the given number of offers (for pagination)
  - [?limit=24](http://server.getoutfit.ru/offers?limit=24) Limit the total number of offers returned (for pagination).  24 is the default
  - [?manufacturer_warranty=true](http://server.getoutfit.ru/offers?manufacturer_warranty=true) Filter the list of offers by manufacturer warranty
  - [?model=adidas](http://server.getoutfit.ru/offers?model=adidas) Limit the list of offers to those containing the given word
  - [?modified_after=1569058481](http://server.getoutfit.ru/offers?modified_after=1569058481) Limit the offers to those modified after the given time (as Unix timestamp)
  - [?modified_before=1569058481](http://server.getoutfit.ru/offers?modified_before=1569058481) Limit the offers to those modified before the given time (as Unix timestamp)
  - [?modified_time=1569058481](http://server.getoutfit.ru/offers?modified_time=1569058481) Limit the offers to those modified exactly at the given time (as Unix timestamp)
  - [?name=кроссовки](http://server.getoutfit.ru/offers?name=кроссовки) Limit the list of offers to those whose name contains a given word
  - [?oldprice=999](http://server.getoutfit.ru/offers?oldprice=999) Limit the offers to those whose old price is equal to a given value
  - [?oldprice_above=999](http://server.getoutfit.ru/offers?oldprice_above=999) Limit the offers to those whose old price is above a given value
  - [?oldprice_below=999](http://server.getoutfit.ru/offers?oldprice_below=999) Limit the offers to those whose old price is below a given value
  - [?picture=600x866](http://server.getoutfit.ru/offers?picture=600x866) Limit the list of offers to those whose picture contains a given word
  - [?price=999](http://server.getoutfit.ru/offers?price=999) Limit the offers to those whose price is equal to a given value
  - [?price_above=999](http://server.getoutfit.ru/offers?price_above=999) Limit the offers to those whose price is above a given value
  - [?price_below=999](http://server.getoutfit.ru/offers?price_below=999) Limit the offers to those whose price is below a given value
  - [?sales_notes=скидки](http://server.getoutfit.ru/offers?sales_notes=скидки) Limit the offers to those whose sales notes contain a given word
  - [?typePrefix=очки](http://server.getoutfit.ru/offers?typePrefix=очки) Limit the offers to those whose type prefix contains a given word
  - [?url=armani](http://server.getoutfit.ru/offers?url=armani) Limit the offers to those whose url contains a given word
  - [?vendor=armani](http://server.getoutfit.ru/offers?vendor=armani) Limit the offers to those whose vendor contains a given word
  - [?vendorCode=0AX4026S](http://server.getoutfit.ru/offers?vendorCode=0AX4026S) Limit the offers to those whose vendor code contains a given word
- [/params](http://server.getoutfit.ru/params) Returns the list of all parameters
  - [?count=true](http://server.getoutfit.ru/params?count=true) Returns the number of parameters instead of their list
- [/prices](http://server.getoutfit.ru/prices) Returns the range of prices for all offers
- [/update](http://server.getoutfit.ru/update) Runs an update of shopping catalogue if last update is older than 24 hours

Categories and offers can be filtered by a combination of parameters.

## HTML Routes
- [/](http://server.getoutfit.ru)
- [/stylist](http://server.getoutfit.ru/stylist?subid=app)

Stylist should be given a subid parameter.
