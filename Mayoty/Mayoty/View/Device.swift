//
//  Device.swift
//  Mayoty
//
//  Created by jeegarden on 6/7/26.
//
import Foundation

struct Device: Identifiable {
    let id: UUID
    let name: String
    var isFinalDefender: Bool
    var isAlive: Bool
    
    init(name: String, isFinalDefender: Bool = false, isAlive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.isFinalDefender = isFinalDefender
        self.isAlive = isAlive
    }
}
