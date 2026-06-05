//
//  WatchConnectionError.swift
//  Mayoty
//
//  Created by jeegarden on 6/5/26.
//
import Foundation
enum WatchConnectionState{
    case idle
    case bluetoothUnavailable
    case scanning
    case connecting
    case connected
    case ready
    case disconnected
    case failed
}

