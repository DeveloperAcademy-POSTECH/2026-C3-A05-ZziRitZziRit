//
//  BLEUUID.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//

import CoreBluetooth

enum BLEUUID {
    static let service = CBUUID(string: "A1B2C3D4-1111-2222-3333-123456789ABC")

    // Watch -> iPhone
    static let answer = CBUUID(string: "A1B2C3D4-1111-2222-3333-123456789ABD")

    // iPhone -> Watch
    static let command = CBUUID(string: "A1B2C3D4-1111-2222-3333-123456789ABE")
}
