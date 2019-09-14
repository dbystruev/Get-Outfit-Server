//
//  XMLManager+XMLParserDelegate.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation
import LoggerAPI

extension XMLManager: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        elements = [:]
        level = 0
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        level += 1
        var counters = elements[elementName] ?? (0, 0, level)
        counters.begin += 1
        elements[elementName] = counters
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        var counters = elements[elementName] ?? (0, 0, level)
        counters.end += 1
        elements[elementName] = counters
        level -= 1
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        Log.info("Finished document, \(elements.count) elements found")
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
    }
}
