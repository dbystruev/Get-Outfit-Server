//
//  URL+Extension.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var queryItems = components?.queryItems ?? []
        for query in queries {
            queryItems += [URLQueryItem(name: query.key, value: query.value)]
        }
        components?.queryItems = queryItems
        return components?.url
    }
}

// MARK: - Comparable
extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.absoluteString < rhs.absoluteString
    }
    
    
}
