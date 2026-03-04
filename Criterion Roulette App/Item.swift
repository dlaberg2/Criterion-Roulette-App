//
//  Item.swift
//  Criterion Roulette App
//
//  Created by Dylan Laberge on 3/4/26.
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
