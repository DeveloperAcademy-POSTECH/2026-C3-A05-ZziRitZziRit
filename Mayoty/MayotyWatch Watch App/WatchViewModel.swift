//
//  WatchViewModel.swift
//  Mayoty
//
//  Created by jeegarden on 6/2/26.
//
import Foundation
import Observation

@Observable
final class WatchViewModel{
    var status: String = "Idle"
    var logs: [String] = []
    
    func addLog(_ text: String){
        logs.insert(text, at: 0)
    }
}
