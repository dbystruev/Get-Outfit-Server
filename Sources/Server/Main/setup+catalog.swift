//
//  setup+catalog.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI

// MARK: - Load Catalog Locally
func loadCatalog(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    let decoder = PropertyListDecoder()
    
    // MARK: Try to load from UserDefaults
    if
        let savedData = UserDefaults.standard.data(forKey: "\(YMLCatalog.self)"),
        let catalog = try? decoder.decode(YMLCatalog.self, from: savedData)
    {
        #if DEBUG
        Log.debug(
            "Found local catalog \(catalog)"
        )
        #endif
        
        completion(catalog, nil)
        return
    }
    
    // MARK: Try to load into XML file/parse it
    xmlManager.loadAndParseLocally(using: "XML/full.xml") { catalog, error in
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
            "Parsed XML catalog \(catalog)"
        )
        #endif
        
        save(catalog)
        completion(catalog, nil)
    }
}

// MARK: - Save Catalog Locally
func save(_ catalog: YMLCatalog) {
    let encoder = PropertyListEncoder()
    guard let encodedCatalog = try? encoder.encode(catalog) else {
        Log.error("Can't encode \(catalog)")
        return
    }
    
    #if DEBUG
    Log.debug("Saving catalog locally \(catalog)")
    #endif
    
    UserDefaults.standard.set(encodedCatalog, forKey: "\(YMLCatalog.self)")
}

// MARK: - Setup Catalog
func setup(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    loadCatalog { catalog, error in
        guard let catalog = catalog, error == nil else {
            completion(nil, error)
            return
        }
        
        #if DEBUG
        Log.debug(
            "Loaded catalog \(catalog)"
        )
        #endif
        
        let yesterday = Date().addingTimeInterval(-86400)
        
        guard let catalogDate = catalog.date, catalogDate < yesterday else {
            completion(catalog, nil)
            return
        }
        
        xmlManager.lastImport = catalogDate
        updateCatalogLocally { updatedCatalog, error in
            if let error = error { Log.error(error.localizedDescription) }
            if let updatedCatalog = updatedCatalog { catalog.update(with: updatedCatalog) }
            #if DEBUG
            Log.debug(
                "Updated catalog locally \(catalog)"
            )
            #endif
            
            guard let updatedCatalogDate = catalog.date, updatedCatalogDate < yesterday else {
                save(catalog)
                completion(catalog, nil)
                return
            }
            
            xmlManager.lastImport = updatedCatalogDate
            updateCatalogFromRemote { remoteCatalog, error in
                if let error = error { Log.error(error.localizedDescription) }
                if let remoteCatalog = remoteCatalog { catalog.update(with: remoteCatalog) }
                #if DEBUG
                Log.debug(
                    "Updated catalog from remote \(catalog)"
                )
                #endif
                
                save(catalog)
                completion(catalog, nil)
            }
        }
    }
}

// MARK: - Update Catalog Locally
func updateCatalogLocally(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    xmlManager.loadAndParseLocally(using: "XML/update.xml", completion: completion)
}

// MARK: - Update Catalog from Remote
func updateCatalogFromRemote(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    xmlManager.loadAndParseFromRemote(using: "XML/update.xml", completion: completion)
}
