//
//  Item.swift
//  Volleyball analysis
//
//  Created by Pieter Bikkel on 04/09/2023.
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
