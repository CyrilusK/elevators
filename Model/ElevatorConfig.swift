//
//  Elevator.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import Foundation

struct ElevatorConfig: Codable {
    let id: Int
    let company: String
    let maxWeight: Int
}

struct BuildingConfig: Codable {
    let timeToElevate: Int
    let timeOpenCloseDoor: Int
    let houseLevels: Int
    let lifts: [ElevatorConfig]
}
