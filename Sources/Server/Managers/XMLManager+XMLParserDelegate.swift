//
//  XMLManager+XMLParserDelegate.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation
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
        let newElement = GenericXMLElement.createElement(withName: elementName, attributes: attributeDict)
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
        if processedElements.last?.elementName == elementName {
            let currentElement = processedElements.removeLast()
            if processedElements.isEmpty {
                rootElement = currentElement
            } else {
                var lastElement = processedElements.removeLast()
                lastElement.addChild(currentElement)
                processedElements.append(lastElement)
            }
        } else {
            let level = processedElements.count
            if let lastElement = processedElements.last {
                Log.error("Starting \(lastElement) does not match ending \(elementName), level: \(level)")
            } else {
                Log.error("Ending \(elementName) has no starting element, level \(level)")
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
        if processedElements.isEmpty {
            if let rootElement = rootElement {
                Log.info("Root Element: \(rootElement.elementName)")
                Log.info("Attributes: \(rootElement.attributes)")
                Log.info("Children: \(rootElement.children)")
            } else {
                Log.error("No root element")
            }
        } else {
            Log.error("\(processedElements.count) elements not matched: \(processedElements)")
        }
        
        #if DEBUG
        Log.info("Parsed \(elements.count) unique elements:")
        for (key, value) in elements.sorted(by: { leftElement, rightElement in
            let leftLevel = leftElement.value.level
            let rightLevel = rightElement.value.level
            if leftLevel == rightLevel {
                return leftElement.key < rightElement.key
            } else {
                return leftLevel < rightLevel
            }
        }) {
            let tabs = String(repeating: "\t", count: value.level)
            let counter = value.begin == value.end ? "\(value.begin)" : "\(value)"
            Log.info("\(tabs)\(key): \(counter)", functionName: "", fileName: "")
        }
        #endif
    }
}
