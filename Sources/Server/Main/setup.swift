//
//  setup.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI
import SwiftRedis

// MARK: - Setup Catalog
func setup(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    
    let xmlManager = XMLManager()
    
    func loadCatalog(completion: @escaping (YMLCatalog?, Error?) -> Void) {
        let decoder = PropertyListDecoder()
        
        // MARK: Try to load from UserDefaults
        if
            let savedData = UserDefaults.standard.data(forKey: "\(YMLCatalog.self)"),
            let catalog = try? decoder.decode(YMLCatalog.self, from: savedData)
        {
            #if DEBUG
            Log.debug(
                "Found local YMLCatalog \(catalog.date?.toString ?? "nil")" +
                ", offers: \(catalog.shop?.offers.count ?? 0)"
            )
            #endif
            
            completion(catalog, nil)
            return
        }
        
        // MARK: Try to load into XML file/parse it
        xmlManager.loadAndParse(using: "XML/full.xml") { catalog, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let catalog = catalog else {
                completion(nil, XMLManager.Errors.emptyCatalog)
                return
            }
            
            #if DEBUG
            Log.debug(
                "Parsed XML YMLCatalog \(catalog.date?.toString ?? "nil")" +
                ", offers: \(catalog.shop?.offers.count ?? 0)"
            )
            #endif
            
            let encoder = PropertyListEncoder()
            guard let encodedCatalog = try? encoder.encode(catalog) else {
                Log.error("Can't encode \(catalog)")
                completion(catalog, nil)
                return
            }
            
            UserDefaults.standard.set(encodedCatalog, forKey: "\(YMLCatalog.self)")
            completion(catalog, nil)
        }
    }
    
    func updateCatalog(completion: @escaping (YMLCatalog?, Error?) -> Void) {
        xmlManager.loadAndParse(using: "XML/update.xml", completion: completion)
    }
    
    loadCatalog { loadedCatalog, error in
        guard let catalog = loadedCatalog, error == nil else {
            completion(loadedCatalog, error)
            return
        }
        
        #if DEBUG
        Log.debug(
            "Loaded YMLCatalog \(catalog.date?.toString ?? "nil")" +
            ", offers: \(catalog.shop?.offers.count ?? 0)"
        )
        #endif
        
        let yesterday = Date().addingTimeInterval(-86400)
        
        if let catalogDate = catalog.date, catalogDate < yesterday {
            xmlManager.lastImport = catalogDate
            updateCatalog { updatedCatalog, error in
                if let error = error {
                    Log.error(error.localizedDescription)
                }
                if let updatedCatalog = updatedCatalog {
                    catalog.update(with: updatedCatalog)
                }
                #if DEBUG
                Log.debug(
                    "Updated YMLCatalog \(catalog.date?.toString ?? "nil")" +
                    ", offers: \(catalog.shop?.offers.count ?? 0)"
                )
                #endif
                completion(catalog, nil)
            }
        } else {
            completion(catalog, nil)
        }
    }
}

// MARK: - Setup Redis
func setup(_ redis: Redis) {
    let host = "localhost"
    let port = Int32(6379)
    
    redis.connect(host: host, port: port) { error in
        if let error = error {
            Log.error("\(error.localizedDescription) at \(host):\(port)")
            return
        }
        
        #if DEBUG
        Log.debug("Connected to Redis at \(host):\(port)")
        #endif
    }
}

// MARK: - Setup Router
func setup(_ router: Router) {
    router.setDefault(templateEngine: StencilTemplateEngine())
    
    // MARK: - GET /
    router.get("/") { request, response, next in
        try response.render("home", context: [:])
        next()
    }
    
    // MARK: - GET /categories
    router.get("categories") { request, response, next in
        var categories = catalog.shop?.categories
        
        // MARK: "id"
        if let id = request.queryParameters["id"] {
            categories = categories?.filter { $0.id == Int(id) }
        }
        
        // MARK: "name"
        if let name = request.queryParameters["name"] {
            categories = categories?.filter { $0.name?.lowercased().contains(name.lowercased()) == true }
        }
        
        // MARK: "parentId"
        if let parentId = request.queryParameters["parentId"] {
            categories = categories?.filter { $0.parentId == Int(parentId) }
        }
        
        // MARK: "count"
        if request.queryParameters["count"] == nil {
            response.send(json: categories)
        } else {
            response.send(json: ["count": categories?.count])
        }
        
        next()
    }
    
    // MARK: - GET /currencies
    router.get("currencies") { request, response, next in
        let currencies = catalog.shop?.currencies
        
        // MARK: "count"
        if request.queryParameters["count"] == nil {
            response.send(json: currencies)
        } else {
            response.send(json: ["count": currencies?.count])
        }
        
        next()
    }
    
    // MARK: - GET /offers
    router.get("offers") { request, response, next in
        var offers = catalog.shop?.offers
        
        if request.queryParameters.isEmpty {
            offers = offers?.filter { $0.available == true }
        }
        
        // MARK: "available"
        if let available = request.queryParameters["available"] {
            offers = offers?.filter { $0.available == Bool(available) }
        }
        
        // MARK: "deleted"
        if let deleted = request.queryParameters["deleted"] {
            offers = offers?.filter { $0.deleted == Bool(deleted) }
        }
        
        // MARK: "id"
        if let id = request.queryParameters["id"] {
            offers = offers?.filter { $0.id?.lowercased() == id.lowercased() }
        }
        
        // MARK: "categoryId"
        if let categoryId = request.queryParameters["categoryId"] {
            offers = offers?.filter { $0.categoryId == Int(categoryId) }
        }
        
        // MARK: "currencyId"
        if let currencyId = request.queryParameters["currencyId"] {
            offers = offers?.filter { $0.currencyId?.lowercased() == currencyId.lowercased() }
        }
        
        // MARK: "description"
        if let description = request.queryParameters["description"] {
            offers = offers?.filter { $0.description?.lowercased().contains(description.lowercased()) == true }
        }
        
        // MARK: "manufacturer_warranty"
        if let manufacturer_warranty = request.queryParameters["manufacturer_warranty"] {
            offers = offers?.filter { $0.manufacturer_warranty == Bool(manufacturer_warranty) }
        }
        
        // MARK: "model"
        if let model = request.queryParameters["model"] {
            offers = offers?.filter { $0.model?.lowercased().contains(model.lowercased()) == true }
        }
        
        // MARK: "modified_after"
        if let modified_after = request.queryParameters["modified_after"] {
            if let userTime = TimeInterval(modified_after) {
                offers = offers?.filter { offer in
                    guard let offerTime = offer.modified_time else { return false }
                    return userTime <= offerTime
                }
            }
        }
        
        // MARK: "modified_before"
        if let modified_before = request.queryParameters["modified_before"] {
            if let userTime = TimeInterval(modified_before) {
                offers = offers?.filter { offer in
                    guard let offerTime = offer.modified_time else { return false }
                    return offerTime <= userTime
                }
            }
        }
        
        // MARK: "modified_time"
        if let modified_time = request.queryParameters["modified_time"] {
            offers = offers?.filter { $0.modified_time == TimeInterval(modified_time) }
        }
        
        // MARK: "name"
        if let name = request.queryParameters["name"] {
            offers = offers?.filter { $0.name?.lowercased().contains(name.lowercased()) == true }
        }
        
        // MARK: "oldprice"
        if let oldprice = request.queryParameters["oldprice"] {
            offers = offers?.filter { $0.oldprice == Decimal(string: oldprice) }
        }
        
        // MARK: "oldprice_above"
        if let oldprice_above = request.queryParameters["oldprice_above"] {
            if let userOldPrice = Decimal(string: oldprice_above) {
                offers = offers?.filter { offer in
                    guard let offerOldPrice = offer.oldprice else { return false }
                    return userOldPrice <= offerOldPrice
                }
            }
        }
        
        // MARK: "oldprice_below"
        if let oldprice_below = request.queryParameters["oldprice_below"] {
            if let userOldPrice = Decimal(string: oldprice_below) {
                offers = offers?.filter { offer in
                    guard let offerOldPrice = offer.oldprice else { return false }
                    return offerOldPrice <= userOldPrice
                }
            }
        }
        
        // MARK: "{params}"
        if let paramNames = offers?.flatMap({ $0.params.compactMap({ param in param.name?.lowercased() }) }) {
            for name in Set(paramNames) {
                if let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    if let value = request.queryParameters[encodedName]?.lowercased() {
                        offers = offers?.filter { offer in
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
        }
        
        // MARK: "picture"
        if let picture = request.queryParameters["picture"] {
            offers = offers?.filter { offer in
                for url in offer.pictures {
                    if url.absoluteString.lowercased().contains(picture.lowercased()) { return true }
                }
                return false
            }
        }
        
        // MARK: "price"
        if let price = request.queryParameters["price"] {
            offers = offers?.filter { $0.price == Decimal(string: price) }
        }
        
        // MARK: "price_above"
        if let price_above = request.queryParameters["price_above"] {
            if let userPrice = Decimal(string: price_above) {
                offers = offers?.filter { offer in
                    guard let offerPrice = offer.price else { return false }
                    return userPrice <= offerPrice
                }
            }
        }
        
        // MARK: "price_below"
        if let price_below = request.queryParameters["price_below"] {
            if let userPrice = Decimal(string: price_below) {
                offers = offers?.filter { offer in
                    guard let offerPrice = offer.price else { return false }
                    return offerPrice <= userPrice
                }
            }
        }
        
        // MARK: "sales_notes"
        if let sales_notes = request.queryParameters["sales_notes"] {
            offers = offers?.filter { $0.sales_notes?.lowercased().contains(sales_notes.lowercased()) == true }
        }
        
        // MARK: "typePrefix"
        if let typePrefix = request.queryParameters["typePrefix"] {
            offers = offers?.filter { $0.typePrefix?.lowercased().contains(typePrefix.lowercased()) == true }
        }
        
        // MARK: "url"
        if let url = request.queryParameters["url"] {
            offers = offers?.filter { $0.url?.absoluteString.lowercased().contains(url.lowercased()) == true }
        }
        
        // MARK: "vendor"
        if let vendor = request.queryParameters["vendor"] {
            offers = offers?.filter { $0.vendor?.lowercased().contains(vendor.lowercased()) == true }
        }
        
        // MARK: "vendorCode"
        if let vendorCode = request.queryParameters["vendorCode"] {
            offers = offers?.filter { $0.vendorCode?.lowercased() == vendorCode.lowercased() }
        }
        
        // MARK: "count"
        if request.queryParameters["count"] == nil {
            if
                request.queryParameters["modified_times"] != nil,
                let modifiedTimes = offers?.compactMap({ $0.modified_time }),
                let minTime = modifiedTimes.min(),
                let maxTime = modifiedTimes.max()
            {
                #if DEBUG
                Log.debug("Min Time: \(minTime), Max Time: \(maxTime)")
                #endif
                
                response.send(json: ["modified_time_min": minTime, "modified_time_max": maxTime])
            } else {
                response.send(json: offers)
            }
        } else {
            response.send(json: ["count": offers?.count])
        }
        
        next()
    }
    
    // MARK: - GET /params
    router.get("params") { request, response, next in
        let isNotCounting = request.queryParameters["count"] == nil
        let offers = catalog.shop?.offers
        
        if let paramNames = offers?.flatMap({ $0.params.compactMap({ param in param.name?.lowercased() }) }) {
            let names = Set(paramNames)
            
            // MARK: "count"
            if isNotCounting {
                response.send(json: names)
            } else {
                response.send(json: ["count": names.count])
            }
        } else {
            if isNotCounting {
                response.send(json: Set<String>())
            } else {
                response.send(json: ["count": 0])
            }
        }
        
        next()
    }
    
    // MARK: - GET /stylist
    router.get("stylist") { request, response, next in
        guard let subid = request.queryParameters["subid"] else {
            try response.status(.badRequest).end()
            return
        }
        
        Log.info("Generated links for subid: \(subid)")
        
        try response.render("stylist", context: ["subid": subid])
        
        next()
    }
}
