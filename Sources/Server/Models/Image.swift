//
//  Image.swift
//
//  Created by Denis Bystruev on 05.03.2020.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Stencil

struct Image: Codable {
    let categoryId: Int?
    let offerId: String?
    var offerURL: String?
    let offerName: String?
    let url: String

    var subid: String {
        if
            let offerURL = offerURL,
            let urlComponents = URLComponents(string: offerURL),
            let queryItems = urlComponents.queryItems
        {
            for queryItem in queryItems {
                if 
                    queryItem.name == "subid",
                    let value = queryItem.value
                {
                    return value
                }
            }
        }
        return ""
    }

    mutating func setSubid(_ subid: String) {
        offerURL = withSubid(subid)
    }

    func withSubid(_ subid: String) -> String? {
        guard let offerURL = offerURL else { return nil }
        guard var urlComponents = URLComponents(string: offerURL) else { return offerURL }
        let newQueryItem = URLQueryItem(name: "subid", value: subid)
        if var queryItems = urlComponents.queryItems {
            queryItems.removeAll { $0.name == "subid" }
            queryItems.append(newQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [newQueryItem]
        }
        return urlComponents.string
    }
}
