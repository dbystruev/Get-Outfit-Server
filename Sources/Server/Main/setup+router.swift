//
//  setup+router.swift
//
//  Created by Denis Bystruev on 21/09/2019.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI

// MARK: - Setup Router
func setup(_ router: Router) {
  router.setDefault(templateEngine: StencilTemplateEngine())

  // MARK: - GET /
  router.get("/") { request, response, next in
    try response.render("home", context: [:])
    next()
  }

  // MARK: - GET /categories
  router.get("/categories") { request, response, next in
    var categories = catalog.shop?.categories ?? []

    // MARK: "id"
    if let ids = request.queryParametersMultiValues["id"]?.compactMap({ Int($0) }),
      !ids.isEmpty
    {
      categories = categories.filter({
        if let id = $0.id {
          return ids.contains(id)
        }
        return false
      })
    }

    // MARK: "name"
    if let name = request.queryParameters["name"] {
      categories = categories.filter { $0.name?.lowercased().contains(name.lowercased()) == true }
    }

    // MARK: "parentId"
    if let parentId = request.queryParameters["parentId"] {
      categories = categories.filter { $0.parentId == Int(parentId) }
    }

    // MARK: "from"
    if let from = request.queryParameters["from"]?.int {
      if 0 < from {
        if from < categories.count {
          categories = Array(categories[from...])
        } else {
          categories = []
        }
      }
    }

    // MARK: "limit"
    let limit = request.queryParameters["limit"]?.int ?? 24
    if 0 <= limit && limit < categories.count {
      categories = Array(categories[..<limit])
    }

    // MARK: "count"
    if request.queryParameters["count"] == nil {
      response.send(json: categories)
    } else {
      response.send(json: ["count": categories.count])
    }

    next()
  }

  // MARK: - GET /currencies
  router.get("/currencies") { request, response, next in
    let currencies = catalog.shop?.currencies

    // MARK: "count"
    if request.queryParameters["count"] == nil {
      response.send(json: currencies)
    } else {
      response.send(json: ["count": currencies?.count])
    }

    next()
  }

  // MARK: - GET /date
  router.get("/date") { request, response, next in
    response.send(json: ["date": catalog.date?.toString])
    next()
  }

  // MARK: - GET /images
  router.get("/images") { request, response, next in
    let requestStartTime = Date()
    var images = catalog.shop?.images ?? []
    var urlParams = ""

    // MARK: "categoryId"
    if let categoryIds = request.queryParametersMultiValues["categoryId"]?.compactMap({ Int($0) }),
      !categoryIds.isEmpty
    {
      images = images.filter({
        if let categoryId = $0.categoryId {
          return categoryIds.contains(categoryId)
        }
        return false
      })
    }

    // MARK: "offerId"
    if let offerIds = request.queryParametersMultiValues["offerId"]?.map({ $0.lowercased() }),
      !offerIds.isEmpty
    {
      images = images.filter({
        if let offerId = $0.offerId?.lowercased() {
          return offerIds.contains(offerId)
        }
        return false
      })
    }

    // MARK: "offerName"
    if let words = request.queryParametersMultiValues["offerName"]?.map({ $0.lowercased() }),
      !words.isEmpty
    {
      urlParams += "&offerName=\(words.joined(separator: "&offerName="))"

      images = images.filter({
        if let offerName = $0.offerName?.lowercased() {
          for word in words {
            guard offerName.contains(word) else { return false }
          }
          return true
        }
        return false
      })
    }

    let total = images.count

    // MARK: "from"
    var from = request.queryParameters["from"]?.int ?? 0
    from = min(images.count - 24, from)
    from = max(0, from)
    images = Array(images[from...])

    // MARK: "format"
    let isHtml = request.queryParameters["format"]?.string.lowercased() == "html"

    // MARK: "limit"
    var limit = isHtml ? 24 : request.queryParameters["limit"]?.int ?? 24
    limit = min(images.count, limit)
    limit = max(0, limit)
    images = Array(images[..<limit])

    // MARK: "duration"
    let isTiming = request.queryParameters["duration"] != nil

    if isTiming {
      let duration = Date().timeIntervalSince(requestStartTime)
      response.send(json: ["duration": duration])
    } else if request.queryParameters["count"] == nil {
      if isHtml {
        let context: [String: Codable] = [
          "images": images,
          "first": from + 1,
          "last": from + limit,
          "left5000": from - 5000,
          "left1000": from - 1000,
          "left500": from - 500,
          "left100": from - 100,
          "left": from - 24,
          "urlParams": urlParams,
          "right": from + 24,
          "right100": from + 100,
          "right500": from + 500,
          "right1000": from + 1000,
          "right5000": from + 5000,
          "total": total,
        ]
        try response.render("images", context: context)
      } else {
        response.send(json: images)
      }
      // MARK: "count"
    } else {
      response.send(json: ["count": images.count])
    }

    next()
  }

  // MARK: - GET /modified_times
  router.get("/modified_times") { request, response, next in
    let offers = catalog.shop?.offers

    if let modifiedTimes = offers?.compactMap({ $0.modified_time }),
      let minTime = modifiedTimes.min(),
      let maxTime = modifiedTimes.max()
    {
      #if DEBUG
        Log.debug("Min Time: \(minTime), Max Time: \(maxTime)")
      #endif

      response.send(json: ["modified_time_min": minTime, "modified_time_max": maxTime])
    }

    next()
  }

  // MARK: - GET /offers
  router.get("/offers") { request, response, next in
    let requestStartTime = Date()

    var offers = catalog.shop?.offers ?? []

    // Show only available offers by default
    if request.queryParameters["available"] == nil && request.queryParameters["deleted"] == nil {
      offers = offers.filter { $0.available == true }
    } else {
      // MARK: "available"
      if let available = request.queryParameters["available"] {
        offers = offers.filter { $0.available == Bool(available) }
      }

      // MARK: "deleted"
      if let deleted = request.queryParameters["deleted"] {
        offers = offers.filter { $0.deleted == Bool(deleted) }
      }
    }

    // MARK: "id"
    if let ids = request.queryParametersMultiValues["id"]?.map({ $0.lowercased() }),
      !ids.isEmpty
    {
      offers = offers.filter({
        if let id = $0.id?.lowercased() {
          return ids.contains(id)
        }
        return false
      })
    }

    // MARK: "categoryId"
    if let categoryIds = request.queryParametersMultiValues["categoryId"]?.compactMap({ Int($0) }),
      !categoryIds.isEmpty
    {
      offers = offers.filter({
        if let categoryId = $0.categoryId {
          return categoryIds.contains(categoryId)
        }
        return false
      })
    }

    // MARK: "corner"
    if let corner = request.queryParameters["corner"]?.lowercased() {
      let categories: [Int?]

      switch corner {
      case "bottomleft":
        categories = []
      case "bottomright":
        categories = []
      case "middleright":
        categories = []
      case "topleft":
        categories = []
      case "topright":
        categories = []
      default:
        categories = catalog.shop?.categories.compactMap({ $0.id }) ?? []
      }
      offers = offers.filter { categories.contains($0.categoryId) }
    }

    // MARK: "currencyId"
    if let currencyId = request.queryParameters["currencyId"] {
      offers = offers.filter { $0.currencyId?.lowercased() == currencyId.lowercased() }
    }

    // MARK: "description"
    if let description = request.queryParameters["description"] {
      offers = offers.filter {
        $0.description?.lowercased().contains(description.lowercased()) == true
      }
    }

    // MARK: "manufacturer_warranty"
    if let manufacturer_warranty = request.queryParameters["manufacturer_warranty"] {
      offers = offers.filter { $0.manufacturer_warranty == Bool(manufacturer_warranty) }
    }

    // MARK: "model"
    if let model = request.queryParameters["model"] {
      offers = offers.filter { $0.model?.lowercased().contains(model.lowercased()) == true }
    }

    // MARK: "modified_after"
    if let modified_after = request.queryParameters["modified_after"] {
      if let userTime = TimeInterval(modified_after) {
        offers = offers.filter { offer in
          guard let offerTime = offer.modified_time else { return false }
          return userTime <= offerTime
        }
      }
    }

    // MARK: "modified_before"
    if let modified_before = request.queryParameters["modified_before"] {
      if let userTime = TimeInterval(modified_before) {
        offers = offers.filter { offer in
          guard let offerTime = offer.modified_time else { return false }
          return offerTime <= userTime
        }
      }
    }

    // MARK: "modified_time"
    if let modified_time = request.queryParameters["modified_time"] {
      offers = offers.filter { $0.modified_time == TimeInterval(modified_time) }
    }

    // MARK: "name"
    if let words = request.queryParametersMultiValues["name"]?.map({ $0.lowercased() }),
      !words.isEmpty
    {
      offers = offers.filter({
        if let name = $0.name?.lowercased() {
          for word in words {
            guard name.contains(word) else { return false }
          }
          return true
        }
        return false
      })
    }

    // MARK: "oldprice"
    if let oldprice = request.queryParameters["oldprice"] {
      offers = offers.filter { $0.oldprice == Decimal(string: oldprice) }
    }

    // MARK: "oldprice_above"
    if let oldprice_above = request.queryParameters["oldprice_above"] {
      if let userOldPrice = Decimal(string: oldprice_above) {
        offers = offers.filter { offer in
          guard let offerOldPrice = offer.oldprice else { return false }
          return userOldPrice <= offerOldPrice
        }
      }
    }

    // MARK: "oldprice_below"
    if let oldprice_below = request.queryParameters["oldprice_below"] {
      if let userOldPrice = Decimal(string: oldprice_below) {
        offers = offers.filter { offer in
          guard let offerOldPrice = offer.oldprice else { return false }
          return offerOldPrice <= userOldPrice
        }
      }
    }

    // MARK: "{params}"
    let paramNames = offers.flatMap({ $0.params.compactMap({ param in param.name?.lowercased() }) })
    for name in Set(paramNames).sorted() {
      if let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        if let value = request.queryParameters[encodedName]?.lowercased() {
          offers = offers.filter { offer in
            for param in offer.params {
              if param.name?.lowercased() == name && param.value?.lowercased() == value {
                return true
              }
            }
            return false
          }
        }
      }
    }

    // MARK: "picture"
    if let picture = request.queryParameters["picture"] {
      offers = offers.filter { offer in
        for url in offer.pictures {
          if url.absoluteString.lowercased().contains(picture.lowercased()) { return true }
        }
        return false
      }
    }

    // MARK: "price"
    if let price = request.queryParameters["price"] {
      offers = offers.filter { $0.price == Decimal(string: price) }
    }

    // MARK: "price_above"
    if let price_above = request.queryParameters["price_above"] {
      if let userPrice = Decimal(string: price_above) {
        offers = offers.filter { offer in
          guard let offerPrice = offer.price else { return false }
          return userPrice <= offerPrice
        }
      }
    }

    // MARK: "price_below"
    if let price_below = request.queryParameters["price_below"] {
      if let userPrice = Decimal(string: price_below) {
        offers = offers.filter { offer in
          guard let offerPrice = offer.price else { return false }
          return offerPrice <= userPrice
        }
      }
    }

    // MARK: "sales_notes"
    if let sales_notes = request.queryParameters["sales_notes"] {
      offers = offers.filter {
        $0.sales_notes?.lowercased().contains(sales_notes.lowercased()) == true
      }
    }

    // MARK: "typePrefix"
    if let typePrefix = request.queryParameters["typePrefix"] {
      offers = offers.filter {
        $0.typePrefix?.lowercased().contains(typePrefix.lowercased()) == true
      }
    }

    // MARK: "url"
    if let url = request.queryParameters["url"] {
      offers = offers.filter {
        $0.url?.absoluteString.lowercased().contains(url.lowercased()) == true
      }
    }

    // MARK: "vendor"
    if let vendor = request.queryParameters["vendor"] {
      offers = offers.filter { $0.vendor?.lowercased().contains(vendor.lowercased()) == true }
    }

    // MARK: "vendorCode"
    if let vendorCode = request.queryParameters["vendorCode"] {
      offers = offers.filter { $0.vendorCode?.lowercased() == vendorCode.lowercased() }
    }

    // MARK: "from"
    if let from = request.queryParameters["from"]?.int {
      if 0 < from {
        if from < offers.count {
          offers = Array(offers[from...])
        } else {
          offers = []
        }
      }
    }

    // MARK: "limit"
    let limit = request.queryParameters["limit"]?.int ?? 24
    if 0 <= limit && limit < offers.count {
      offers = Array(offers[..<limit])
    }

    let isCounting = request.queryParameters["count"] != nil
    let isTiming = request.queryParameters["duration"] != nil

    if isTiming {
      // MARK: "duration"
      let duration = Date().timeIntervalSince(requestStartTime)
      response.send(json: ["duration": duration])
    } else if isCounting {
      // MARK: "count"
      response.send(json: ["count": offers.count])
    } else {
      response.send(json: offers)
    }

    next()
  }

  // MARK: - GET /params
  router.get("/params") { request, response, next in
    let isCounting = request.queryParameters["count"] != nil
    let offers = catalog.shop?.offers

    if let paramNames = offers?.flatMap({
      $0.params.compactMap({ param in param.name?.lowercased() })
    }) {
      let names = Set(paramNames).sorted()
      var result = [String: [String]]()

      for name in names {
        if let paramValues = offers?.flatMap({
          $0.params
            .filter({ param in param.name?.lowercased() == name })
            .compactMap({ param in param.value })
        }) {
          result[name] = Set(paramValues).sorted()
        }
      }

      // MARK: "count"
      if isCounting {
        response.send(json: ["count": result.count])
      } else {
        response.send(json: result)
      }
    } else {
      if isCounting {
        response.send(json: ["count": 0])
      } else {
        response.send(json: [String: [String]]())
      }
    }

    next()
  }

  // MARK: "/prices"
  router.get("/prices") { request, response, next in
    let offers = catalog.shop?.offers

    if let priceRange = offers?.compactMap({ $0.price }),
      let minPrice = priceRange.min(),
      let maxPrice = priceRange.max()
    {
      #if DEBUG
        Log.debug("Min Price: \(minPrice), Max Price: \(maxPrice)")
      #endif

      response.send(json: ["price_min": minPrice, "price_max": maxPrice])
    }

    next()
  }

  // MARK: - GET /stylist
  router.get("/stylist") { request, response, next in
    guard let subid = request.queryParameters["subid"] else {
      try response.status(.badRequest).end()
      return
    }

    Log.info("Generated links for subid: \(subid)")

    try response.render("stylist", context: ["subid": subid])

    next()
  }

  // MARK: - GET /update
  router.get("/update") { request, response, next in
    updateCatalog()
    response.send(json: ["date": catalog.date?.toString])
    next()
  }
}
