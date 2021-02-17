//
//  String+Extension.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Foundation

extension String {
    var lowercasedLetters: String {
        lowercased().filter { $0.isLowercase }
    }
    
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
    
    var uppercasedLetters: String {
        uppercased().filter { $0.isUppercase }
    }
}
