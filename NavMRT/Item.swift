//
//  Item.swift
//  NavMRT
//
//  Created by Voraphol Lertchaiudomchok on 13/11/2568 BE.
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
