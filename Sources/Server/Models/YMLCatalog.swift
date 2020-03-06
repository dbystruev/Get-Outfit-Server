//
//  YMLCatalog.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/export/yml.html

import Foundation
import LoggerAPI

class YMLCatalog: Codable {
  var date: Date?
  var shop: YMLShop?

  init() {
    date = Date(timeIntervalSince1970: 0)
    shop = nil
  }

  func clearImages() {
    shop?.images = []
  }

  func reloadImages() {
    shop?.reloadImages()
    Log.info("\(shop?.offers.count ?? 0) offers and \(shop?.images.count ?? 0) images loaded")
  }
}

// MARK: - XMLElement
extension YMLCatalog: XMLElement {
  var attributes: [String: String] {
    get {
      guard let date = date else { return [:] }
      return ["date": date.toString]
    }
    set {
      guard let dateString = newValue["date"] else { return }
      self.date = dateString.toDate
    }
  }

  var children: [XMLElement] {
    if let shop = shop {
      return [shop]
    } else {
      return []
    }
  }

  var elementName: String {
    return "yml_catalog"
  }

  func addChild(_ child: XMLElement) {
    if let shop = child as? YMLShop {
      self.shop = shop
    }
  }

  func update(with element: XMLElement) {
    if let catalog = element as? Self {
      date = catalog.date ?? date
      if let updatedShop = catalog.shop {
        if shop == nil {
          shop = updatedShop
        } else {
          shop?.update(with: updatedShop)
        }
      }
    }
  }
}

extension YMLCatalog {
  convenience init(attributes: [String: String]) {
    self.init()
    self.attributes = attributes
  }
}

#if DEBUG
  // MARK: - CustomStringConvertible
  extension YMLCatalog: CustomStringConvertible {
    var description: String {
      return "\(date?.toString ?? "nil"), offers: \(shop?.offers.count ?? 0)"
    }
  }
#endif
