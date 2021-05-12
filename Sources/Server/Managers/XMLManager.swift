//
//  XMLManager.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

// FoundationXML and FoundationNetworking is for Linux only
#if canImport(FoundationXML)
import FoundationXML
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Foundation
import LoggerAPI

class XMLManager: NSObject {
    // MARK: - Errors
    enum Errors: Swift.Error {
        case alreadyDownloading
        case cantCreateXMLParser(URL)
        case cantParse
        case emptyCatalog
        case invalidLocalURL(String)
        case invalidRemoteURL(String)
        case noLocalData(String)
        case noRemoteData(URL)
        case noRootElement
        case notMatchedElements([XMLElement])
        case rootElementIsNotYMLCatalog(XMLElement)
        
        var description: String {
            switch self {
            case .alreadyDownloading:
                return "Already downloading"
            case .cantCreateXMLParser(let url):
                return "Can't create XML parser for \(url)"
            case .cantParse:
                return "Unknown parsing error: can't parse"
            case .emptyCatalog:
                return "Catalogue is empty"
            case .invalidLocalURL(let path):
                return "Invalid local URL \(path)"
            case .invalidRemoteURL(let path):
                return "Invalid remote URL \(path)"
            case .noLocalData(let path):
                return "No local data at \(path)"
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
    var isDownloading = false
    var parserDidEndDocumentCalled = false
    var processedElements = [XMLElement]()
    var rootElement: XMLElement?

    lazy var remotePath = remoteShop.path
    
    // Get remote parameters from Admitad
    lazy var remoteParameters = [
        "currency": remoteShop.currency,
        "code": remoteShop.code,
        "feed_id": remoteShop.feed_id,
        "last_import": remoteShop.last_import,
        "template": remoteShop.template,
        "user": remoteShop.user,
        "format": remoteShop.format,
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
            guard let lastImport = remoteParameters["last_import"], let lastImportDate = lastImport else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd.HH.mm"
            return formatter.date(from: lastImportDate)
        }
        set {
            guard let date = newValue else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd.HH.mm"
            remoteParameters["last_import"] = formatter.string(from: date)
        }
    }
    
    var localURL: URL? {
        guard let localPath = localPath else { return nil }
        return getWorkingDirectory().appendingPathComponent(localPath)
    }
    
    // MARK: - Methods
    func loadAndParseLocally(using localPath: String, completion: @escaping (YMLCatalog?, Error?) -> Void) {
        self.localPath = localPath
        guard isLoaded else {
            completion(nil, Errors.noLocalData(localURL?.path ?? "nil"))
            return
        }
        #if DEBUG
        Log.debug("Found local \(localPath)")
        #endif
        
        parseLoaded(completion: completion)
    }
    
    func loadAndParseFromRemote(using localPath: String, completion: @escaping (YMLCatalog?, Error?) -> Void) {
        self.localPath = localPath
        updateFromRemote { error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            self.parseLoaded(completion: completion)
        }
    }
    
    func parseLoaded(completion: @escaping (YMLCatalog?, Error?) -> Void) {
        Log.debug("Selected \(remoteShop.name) store")
    
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

            guard parser.parse() else {
                if let error = parser.parserError {
                    completion(nil, error)
                } else {
                    completion(nil, XMLManager.Errors.cantParse)
                }
                return
            }

            #if DEBUG
            Log.debug("Parse success")
            #endif

            // BUG in Linux: parserDidEndDocument(_:) is not called automatically
            if !self.parserDidEndDocumentCalled {
                self.parserDidEndDocument(parser)
            }
            // completion(catalog, nil)
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

        guard !isDownloading else {
            completion(Errors.alreadyDownloading)
            return
        }

        isDownloading = true
        
        #if DEBUG
        Log.debug("Started downloading from \(url.absoluteString)")
        #endif
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            self.isDownloading = false

            #if DEBUG
            Log.debug("Finished downloading \(url.absoluteString) \(error?.localizedDescription ?? "")")
            #endif

            guard error == nil else {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(Errors.noRemoteData(url))
                return
            }
            
            #if DEBUG
            Log.debug("Saving update to \(localURL.path)")
            #endif
            
            do {
                try data.write(to: localURL, options: .atomic)
                completion(nil)
            } catch let writeError {
                completion(writeError)
            }
        }
        task.resume()
    }
}
