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
    var modified_time: TimeInterval? // since 1970.01.01
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
        var children = [XMLElement]()
        
        if let categoryId = categoryId {
            children.append(GenericXMLElement(characters: "\(categoryId)", elementName: "categoryId"))
        }
        
        if let currencyId = currencyId {
            children.append(GenericXMLElement(characters: currencyId, elementName: "currencyId"))
        }
        
        if let description = description {
            children.append(GenericXMLElement(characters: description, elementName: "description"))
        }
        
        if let manufacturer_warranty = manufacturer_warranty {
            children.append(GenericXMLElement(
                characters: "\(manufacturer_warranty)",
                elementName: "manufacturer_warranty"
            ))
        }
        
        if let model = model {
            children.append(GenericXMLElement(characters: model, elementName: "model"))
        }
        
        if let modified_time = modified_time {
            children.append(GenericXMLElement(
                characters: "\(modified_time)",
                elementName: "modified_time"
            ))
        }
        
        if let name = name {
            children.append(GenericXMLElement(characters: name, elementName: "name"))
        }
        
        if let oldprice = oldprice {
            children.append(GenericXMLElement(characters: "\(oldprice)", elementName: "oldprice"))
        }
        
        params.forEach { children.append($0) }
        
        pictures.forEach { url in
            children.append(GenericXMLElement(characters: url.absoluteString, elementName: "picture"))
        }
        
        if let price = price {
            children.append(GenericXMLElement(characters: "\(price)", elementName: "price"))
        }
        
        if let sales_notes = sales_notes {
            children.append(GenericXMLElement(characters: sales_notes, elementName: "sales_notes"))
        }
        
        if let typePrefix = typePrefix {
            children.append(GenericXMLElement(characters: typePrefix, elementName: "typePrefix"))
        }
        
        if let url = url {
            children.append(GenericXMLElement(characters: url.absoluteString, elementName: "url"))
        }
        
        if let vendor = vendor {
            children.append(GenericXMLElement(characters: vendor, elementName: "vendor"))
        }
        
        if let vendorCode = vendorCode {
            children.append(GenericXMLElement(characters: vendorCode, elementName: "vendorCode"))
        }
        
        return children
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
            modified_time = TimeInterval(child.characters)
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
