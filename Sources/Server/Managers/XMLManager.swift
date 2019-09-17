//
//  XMLManager.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation
import LoggerAPI

class XMLManager: NSObject {
    // MARK: - Errors
    enum Errors: Swift.Error {
        case cantCreateXMLParser(URL)
        case emptyCatalog
        case invalidLocalURL(String)
        case invalidRemoteURL(String)
        case noRemoteData(URL)
        case noRootElement
        case notMatchedElements([XMLElement])
        case rootElementIsNotYMLCatalog(XMLElement)
        
        var description: String {
            switch self {
            case .cantCreateXMLParser(let url):
                return "Can't create XML parser for \(url)"
            case .emptyCatalog:
                return "Catalogue is empty"
            case .invalidLocalURL(let path):
                return "Invalid local URL \(path)"
            case .invalidRemoteURL(let path):
                return "Invalid remote URL \(path)"
            case .noRemoteData(let url):
                return "No remote data at \(url)"
            case .noRootElement:
                return "No root element found"
            case .notMatchedElements(let elements):
                return "\(elements.count) element(s) not matched: \(elements)"
            case .rootElementIsNotYMLCatalog(let element):
                return "Root element is not a YMLCatalog: \(element)"
            }
        }
    }
    
    // MARK: - Static Properties
    static let xmlParserQueue = DispatchQueue(label: "XMLManager.xmlParserQueue")
    
    // MARK: - Stored Properties
    #if DEBUG
    var elements = [String: (begin: Int, end: Int, level: Int)]()
    var level = 0
    #endif
    
    var completion: ((YMLCatalog?, Error?) -> Void)?
    var processedElements = [XMLElement]()
    var rootElement: XMLElement?
    
    var remotePath = "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/"
    
    var remoteParameters = [
        "currency": "RUB",
        "code": "0khxm6hgw5",
        "feed_id": "15540",
        "last_import": "2000.01.01.00.00",
        "template": "45655",
        "user": "Kimsanzhiev",
    ]
    
    var localPath: String?
    
    // MARK: - Computed Properties
    var isLoaded: Bool {
        guard let fullPath = localURL?.path else { return false }
        var isDirectory = ObjCBool(true)
        let fileExists = FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)
        let isReadable = FileManager.default.isReadableFile(atPath: fullPath)
        return fileExists && isReadable && !isDirectory.boolValue
    }
    
    var lastImport: Date? {
        get {
            guard let lastImport = remoteParameters["last_import"] else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd.HH.mm"
            return formatter.date(from: lastImport)
        }
        set {
            guard let date = newValue else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd.HH.mm"
            remoteParameters["last_import"] = formatter.string(from: date)
        }
    }
    
    var localURL: URL? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let localPath = localPath else { return nil }
        return urls.first?.appendingPathComponent(localPath)
    }
    
    // MARK: - Methods
    func loadAndParse(using localPath: String, completion: @escaping (YMLCatalog?, Error?) -> Void) {
        self.localPath = localPath
        if isLoaded {
            #if DEBUG
            Log.debug("Found local \(localPath)")
            #endif
            
            parseLoaded(completion: completion)
        } else {
            updateFromRemote { error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                self.parseLoaded(completion: completion)
            }
        }
    }
    
    func parseLoaded(completion: @escaping (YMLCatalog?, Error?) -> Void) {
        guard let localURL = localURL else {
            completion(nil, Errors.invalidLocalURL(localPath ?? "nil"))
            return
        }
        
        self.completion = completion
        
        XMLManager.xmlParserQueue.async {
            guard let parser = XMLParser(contentsOf: localURL) else {
                completion(nil, Errors.cantCreateXMLParser(localURL))
                return
            }
            
            parser.delegate = self
            parser.parse()
        }
    }
    
    func updateFromRemote(completion: @escaping (Error?) -> Void) {
        guard let localURL = localURL else {
            completion(Errors.invalidLocalURL(localPath ?? "nil"))
            return
        }
        
        guard let url = URL(string: remotePath)?.withQueries(remoteParameters) else {
            completion(Errors.invalidRemoteURL(remotePath))
            return
        }
        
        #if DEBUG
        Log.debug(url.absoluteString)
        #endif
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(Errors.noRemoteData(url))
                return
            }
            
            do {
                try data.write(to: localURL, options: .atomicWrite)
                completion(nil)
            } catch let writeError {
                completion(writeError)
            }
        }
        task.resume()
    }
}
