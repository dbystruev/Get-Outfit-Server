//
//  setup+catalog.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI

// MARK: - Try to load catalog locally
func getLocalCatalog() -> YMLCatalog? {
    let jsonURL = getLocalPermanentStorageURL()
    
    do {
        let savedData = try Data(contentsOf: jsonURL)
        let catalog = try JSONDecoder().decode(YMLCatalog.self, from: savedData)
        
        #if DEBUG
        Log.debug("Found saved catalog \(catalog) in \(jsonURL)")
        #endif
        
        catalog.reloadImages()
        
        return catalog

    } catch let error {
        #if DEBUG
        Log.debug("ERROR reading catalog data from \(jsonURL): \(error.localizedDescription)")
        #endif
    }
    
    return nil
}

// MARK: - Get the URL of local permanent storage file
func getLocalPermanentStorageURL() -> URL {
    let jsonName = "\(remoteShop.name).json"
    let jsonURL = getWorkingDirectory().appendingPathComponent(jsonName)
    return jsonURL
}

func getLocalUpdateFilePath() -> String {
    let updatePath = "\(remoteShop.name)_update.xml"
    return updatePath
}

// MARK: - Get Default Document Directory
func getWorkingDirectory() -> URL {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let workingDirectory = documentDirectory.appendingPathComponent("get_outfit_server")
    var isDirectory = ObjCBool(true)
    let fileExists = FileManager.default.fileExists(
        atPath: workingDirectory.path, isDirectory: &isDirectory)
    guard fileExists && isDirectory.boolValue else {
        do {
            try FileManager.default.createDirectory(
                at: workingDirectory, withIntermediateDirectories: true)
            return workingDirectory
        } catch let error {
            Log.error(
                "ERROR: Can't create directory at \(workingDirectory.path) due to \(error.localizedDescription)"
            )
            return documentDirectory
        }
    }
    return workingDirectory
}

// MARK: - Save Catalog Locally
func save(_ catalog: YMLCatalog) {
    defer {
        catalog.reloadImages()
    }
    catalog.clearImages()
    
    guard let encodedCatalog = try? JSONEncoder().encode(catalog) else {
        Log.error("Can't encode \(catalog)")
        return
    }
    
    let jsonURL = getLocalPermanentStorageURL()
    
    #if DEBUG
    Log.debug("Saving catalog \(catalog) to \(jsonURL)")
    #endif
    
    do {
        try encodedCatalog.write(to: jsonURL, options: .atomic)
    } catch let error {
        Log.error("ERROR writing catalog \(catalog) to \(jsonURL): \(error.localizedDescription)")
    }
}

// MARK: - Setup Catalog
func setupCatalog() {
    // Try to load catalog from local file
    guard let localCatalog = getLocalCatalog() else {
        // Try to download XML file and parse it
        updateCatalog()
        return
    }
    
    catalog.date = localCatalog.date
    catalog.shop = localCatalog.shop
}

// MARK: - Update Catalog if needed
func updateCatalog() {
    let yesterday = Date().addingTimeInterval(-86400)
    
    guard let updatedCatalogDate = catalog.date, updatedCatalogDate < yesterday else { return }
    
    xmlManager.lastImport = updatedCatalogDate
    
    updateCatalogFromRemote { remoteCatalog, error in
        if let error = error { Log.error(error.localizedDescription) }
        if let remoteCatalog = remoteCatalog { catalog.update(with: remoteCatalog) }
        #if DEBUG
        Log.debug("Updated catalog \(catalog) from remote \(catalog)")
        #endif
        save(catalog)
    }
}

// MARK: - Update Catalog from Remote
func updateCatalogFromRemote(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    let localUpdatePath = getLocalUpdateFilePath()
    xmlManager.loadAndParseFromRemote(using: localUpdatePath, completion: completion)
}

// MARK: - Update Catalog Locally
func updateCatalogLocally(completion: @escaping (YMLCatalog?, Error?) -> Void) {
    let localUpdatePath = getLocalUpdateFilePath()
    xmlManager.loadAndParseLocally(using: localUpdatePath, completion: completion)
}
