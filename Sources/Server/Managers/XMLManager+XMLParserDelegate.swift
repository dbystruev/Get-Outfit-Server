//
//  XMLManager+XMLParserDelegate.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation
import HTMLEntities
import LoggerAPI

extension XMLManager: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        processedElements = []
        
        #if DEBUG
        elements = [:]
        level = 0
        #endif
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        var unescapedAttributes = [String: String]()
        for (key, value) in attributeDict {
            unescapedAttributes[key] = value.htmlUnescape()
        }
        
        let newElement = GenericXMLElement.createElement(withName: elementName, attributes: unescapedAttributes)
        processedElements.append(newElement)
        
        #if DEBUG
        level += 1
        var counters = elements[elementName] ?? (0, 0, level)
        counters.begin += 1
        elements[elementName] = counters
        #endif
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !processedElements.isEmpty else { return }
        var lastElement = processedElements.removeLast()
        lastElement.foundCharacters(string)
        processedElements.append(lastElement)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
//        #if DEBUG
//        Log.debug("\(elementName), \(processedElements)")
//        #endif
        
        if processedElements.isEmpty {
            Log.error("Ending \(elementName) has no starting element")
        } else {
            var currentElement = processedElements.removeLast()
            if currentElement.elementName == elementName {
                currentElement.characters = currentElement.characters.htmlUnescape()
                if processedElements.isEmpty {
                    rootElement = currentElement
                } else {
                    var lastElement = processedElements.removeLast()
                    lastElement.addChild(currentElement)
                    processedElements.append(lastElement)
                }
            } else {
                let level = processedElements.count + 1
                Log.error("Starting \(currentElement) does not match ending \(elementName), level: \(level)")
            }
        }
        
        #if DEBUG
        var counters = elements[elementName] ?? (0, 0, level)
        counters.end += 1
        elements[elementName] = counters
        level -= 1
        #endif
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        guard processedElements.isEmpty else {
            completion?(nil, Errors.notMatchedElements(processedElements))
            return
        }
        
        guard let rootElement = rootElement else {
            completion?(nil, Errors.noRootElement)
            return
        }
        
        guard let catalog = rootElement as? YMLCatalog else {
            completion?(nil, Errors.rootElementIsNotYMLCatalog(rootElement))
            return
        }
        
//        #if DEBUG
//        Log.debug("Parsed \(elements.count) unique elements:")
//        
//        for (key, value) in elements.sorted(by: { leftElement, rightElement in
//            let leftLevel = leftElement.value.level
//            let rightLevel = rightElement.value.level
//            if leftLevel == rightLevel {
//                return leftElement.key < rightElement.key
//            } else {
//                return leftLevel < rightLevel
//            }
//        }) {
//            let tabs = String(repeating: "\t", count: value.level)
//            let counter = value.begin == value.end ? "\(value.begin)" : "\(value)"
//            Log.debug("\(tabs)\(key): \(counter)", functionName: "", fileName: "")
//        }
//        #endif
        
        completion?(catalog, nil)
    }
}
