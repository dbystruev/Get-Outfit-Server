//
//  YMLShop.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/elements/shop.html
// <name> replaced with <title>

import Foundation
import LoggerAPI

struct YMLShop: Codable {
  var categories = [YMLCategory]()
  var company: String?
  var currencies = [YMLCurrency]()
  var images: [Image] = []
  var offers = [YMLOffer]()
  var title: String?
  var url: URL?

  mutating func reloadImages() {
    images = offers.filter { $0.available == true }.flatMap({ offer in
      offer.pictures.compactMap({
        $0 == nil
          ? nil
          : Image(
            url: $0!.absoluteString,
            offerId: offer.id ?? "No offer id",
            offerURL: offer.url?.absoluteString ?? "No offer URL",
            offerName: offer.name ?? "No offer name"
          )
      })
    }).sorted { $0.offerName < $1.offerName }
    #if DEBUG
      Log.debug("\(images.count) images reloaded")
    #endif
  }
}

// MARK: - XMLElement
extension YMLShop: XMLElement {
  var children: [XMLElement] {
    var children = [XMLElement]()

    if let title = title {
      children.append(GenericXMLElement(characters: title, elementName: "title"))
    }

    if let company = company {
      children.append(GenericXMLElement(characters: company, elementName: "company"))
    }

    if let url = url {
      children.append(GenericXMLElement(characters: url.absoluteString, elementName: "url"))
    }

    if !categories.isEmpty {
      children.append(GenericXMLElement(children: categories, elementName: "categories"))
    }

    if !currencies.isEmpty {
      children.append(GenericXMLElement(children: currencies, elementName: "currencies"))
    }

    if !offers.isEmpty {
      children.append(GenericXMLElement(children: offers, elementName: "offers"))
    }

    return children
  }

  var elementName: String {
    return "shop"
  }

  mutating func addChild(_ child: XMLElement) {
    //        #if DEBUG
    //        Log.debug("\(child.elementName), children: \(child.children)")
    //        #endif

    switch child.elementName {
    case "title":
      title = child.characters
    case "company":
      company = child.characters
    case "url":
      url = URL(string: child.characters)
    case "categories":
      for element in child.children {
        if let category = element as? YMLCategory {
          categories.append(category)
        }
      }
    case "currencies":
      for element in child.children {
        if let currency = element as? YMLCurrency {
          currencies.append(currency)
        }
      }
    case "offers":
      for element in child.children {
        if let offer = element as? YMLOffer {
          offers.append(offer)
        }
      }
    default:
      break
    }
  }

  mutating func update(with element: XMLElement) {
    guard let updatedShop = element as? Self else { return }

    title = updatedShop.title ?? title
    company = updatedShop.company ?? company
    url = updatedShop.url ?? url

    for updatedCategory in updatedShop.categories {
      if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
        categories[index].update(with: updatedCategory)
      } else {
        categories.append(updatedCategory)
      }
    }

    for updatedCurrency in updatedShop.currencies {
      if let index = currencies.firstIndex(where: { $0.id == updatedCurrency.id }) {
        currencies[index].update(with: updatedCurrency)
      } else {
        currencies.append(updatedCurrency)
      }
    }

    var newOffers = [YMLOffer]()

    for updatedOffer in updatedShop.offers {
      if let index = offers.firstIndex(where: { $0.id == updatedOffer.id }) {
        offers[index] = updatedOffer
      } else {
        newOffers.append(updatedOffer)
      }
    }

    offers.append(contentsOf: newOffers)
  }
}

// MARK: - Dummy Shop
extension YMLShop {
  static var emptyShop: YMLShop {
    return YMLShop(
      categories: [],
      company: "Empty Company",
      currencies: [],
      offers: [],
      title: "Empty Shop",
      url: URL(string: "http://getoutfit.ru")
    )
  }
}

#if DEBUG
  // MARK: - CustomStringConvertible
  extension YMLShop: CustomStringConvertible {
    var description: String {
      var properties = ""
      if let title = title { properties += "title: \"\(title)\", " }
      if let company = company { properties += "company: \"\(company)\", " }
      if let url = url { properties += "url: \"\(url)\", " }
      if !categories.isEmpty {
        properties += "categories: \(categories.count) (last: \(categories.last!)), "
      }
      if !currencies.isEmpty { properties += "currencies: \(currencies), " }
      if !offers.isEmpty { properties += "offers: \(offers.count) (last: \(offers.last!), " }

      let name = "\(YMLShop.self)"
      if properties.isEmpty {
        return name
      } else {
        return "\(name)(\(properties.dropLast(2)))"
      }
    }
  }
#endif
