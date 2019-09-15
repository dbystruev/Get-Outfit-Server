//
//  YMLOffer.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/export/vendor-model.html

import Foundation
import LoggerAPI

struct YMLOffer: Codable {
    var available: Bool?
    var deleted: Bool?
    var id: String?
    var categoryId: Int?
    var currencyId: String?
    var description: String?
    var manufacturer_warranty: Bool?
    var model: String?
    var modified_time: Date?
    var name: String?
    var oldprice: Decimal?
    var params = [YMLParam]()
    var pictures = [URL]()
    var price: Decimal?
    var sales_notes: String?
    var typePrefix: String?
    var url: URL?
    var vendor: String?
    var vendorCode: String?
}

// MARK: - XMLElement
extension YMLOffer: XMLElement {
    var attributes: [String : String] {
        get {
            var attributes = [String: String]()
            attributes["id"] = id
            return attributes
        }
        set {
            available = Bool(newValue["available"] ?? "false")
            deleted = Bool(newValue["deleted"] ?? "false")
            id = newValue["id"]
        }
    }
    
    var children: [XMLElement] {
        Log.error("Not implemented")
        return []
    }
    
    var elementName: String {
        return "offer"
    }
    
    mutating func addChild(_ child: XMLElement) {
        switch child.elementName {
        case "categoryId":
            categoryId = Int(child.characters)
        case "currencyId":
            currencyId = child.characters
        case "description":
            description = child.characters
        case "manufacturer_warranty":
            manufacturer_warranty = Bool(child.characters)
        case "model":
            model = child.characters
        case "modified_time":
            if let time = TimeInterval(child.characters) {
                modified_time = Date(timeIntervalSince1970: time)
            }
        case "name":
            name = child.characters
        case "oldprice":
            oldprice = Decimal(string: child.characters)
        case "param":
            if let param = child as? YMLParam {
                params.append(param)
            }
        case "picture":
            if let url = URL(string: child.characters) {
                pictures.append(url)
            }
        case "price":
            price = Decimal(string: child.characters)
        case "sales_notes":
            sales_notes = child.characters
        case "typePrefix":
            typePrefix = child.characters
        case "url":
            url = URL(string: child.characters)
        case "vendor":
            vendor = child.characters
        case "vendorCode":
            vendorCode = child.characters
        default:
            break
        }
    }
}

extension YMLOffer {
    init(attributes: [String : String]) {
        self.attributes = attributes
    }
}
