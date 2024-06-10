//
//  Elevator.swift
//  Elevators
//
//  Created by Cyril Kardash on 08.06.2024.
//

import Foundation

struct Elevator {
    let id: Int
    let company: String
    let maxWeight: Int
    var currentFloor: Int
    var isMoving: Bool
    
    init(config: ElevatorConfig) {
        self.id = config.id
        self.company = config.company
        self.maxWeight = config.maxWeight
        self.currentFloor = 1
        self.isMoving = false
    }
}
