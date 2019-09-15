//
//  Date+Extension.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation

extension Date {
    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
