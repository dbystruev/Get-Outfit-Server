//
//  setup+catalog.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI

// MARK: - Get Default Document Directory
func getWorkingDirectory() -> URL {
  let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  let workingDirectory = documentDirectory.appendingPathComponent("get_outfit_server")
  var isDirectory = ObjCBool(true)
  let fileExists = FileManager.default.fileExists(
    atPath: workingDirectory.path, isDirectory: &isDirectory)
  guard fileExists && isDirectory.boolValue else {
    do {
      try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true)
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

// MARK: - Try to load catalog locally
func getLocalCatalog() -> YMLCatalog? {
  let filename = getWorkingDirectory().appendingPathComponent("catalog.json")

  do {
    let savedData = try Data(contentsOf: filename)
    let catalog = try JSONDecoder().decode(YMLCatalog.self, from: savedData)
    catalog.reloadImages()

    #if DEBUG
      Log.debug("Found saved catalog \(catalog) in \(filename)")
    #endif

    return catalog

  } catch let error {
    #if DEBUG
      Log.debug("ERROR reading catalog data from \(filename): \(error.localizedDescription)")
    #endif
  }

  return nil
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

  let filename = getWorkingDirectory().appendingPathComponent("catalog.json")

  #if DEBUG
    Log.debug("Saving catalog \(catalog) to \(filename)")
  #endif

  do {
    try encodedCatalog.write(to: filename, options: .atomic)
  } catch let error {
    Log.error("ERROR writing catalog \(catalog) to \(filename): \(error.localizedDescription)")
  }
}

// MARK: - Setup Catalog
func setupCatalog() {
  // Try to load catalog from local file
  if let localCatalog = getLocalCatalog() {
    catalog.date = localCatalog.date
    catalog.shop = localCatalog.shop
  }

  // Try to download XML file and parse it
  updateCatalog()
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
  xmlManager.loadAndParseFromRemote(using: "update.xml", completion: completion)
}

// MARK: - Update Catalog Locally
func updateCatalogLocally(completion: @escaping (YMLCatalog?, Error?) -> Void) {
  xmlManager.loadAndParseLocally(using: "update.xml", completion: completion)
}
