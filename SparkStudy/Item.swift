//
//  Item.swift
//  SparkStudy
//
//  Created by Oliver Tran on 2/5/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
