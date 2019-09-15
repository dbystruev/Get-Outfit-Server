//
//  String+Extension.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation

extension String {
    var toDate: Date? {
        let formats = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd HH:mm", "yyyy-MM-dd", "yyyy-MM"]
        let formatter = DateFormatter()
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) {
                return date
            }
        }
        return nil
    }
}
