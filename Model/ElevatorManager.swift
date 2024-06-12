//
//  ElevatorManager.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import Foundation

class ElevatorManager {
    var config: BuildingConfig
    var lifts: [Elevator]
    weak var delegate: ElevatorPresenter?

    init(config: BuildingConfig) {
        self.config = config
        self.lifts = config.lifts.map { Elevator(config: $0) }
    }
    
    func requestLift(toFloor floor: Int) {
        guard floor > 0 && floor <= config.houseLevels else {
            delegate?.view?.showError(message: "Invalid floor request")
            return
        }
        
        let availableLifts = lifts.filter { !$0.isMoving }
        
        if availableLifts.isEmpty {
            delegate?.view?.showError(message: "All lifts are currently busy")
            return
        }
        
        let closestLift = availableLifts.min(by: { abs($0.currentFloor - floor) < abs($1.currentFloor - floor)} )
        
        if let lift = closestLift {
            moveLift(lift, toFloor: floor)
        }
    }

    func moveLift(_ lift: Elevator, toFloor floor: Int) {
        guard let liftIndex = lifts.firstIndex(where: { $0.id == lift.id }) else {
            delegate?.view?.showError(message: "Lift not found")
            return
        }
        
        lifts[liftIndex].isMoving = true
        
        let floorsToMove = abs(lifts[liftIndex].currentFloor - floor)
        let travelTime = Double(floorsToMove) * config.timeToElevate
        
        self.delegate?.liftWillArrive(lift: lift, floor: floor)
        print("Lift \(lift.id) is moving from floor \(lifts[liftIndex].currentFloor) to floor \(floor)")
        DispatchQueue.global().asyncAfter(deadline: .now() + Double(travelTime)) {
            DispatchQueue.main.async {
                self.lifts[liftIndex].currentFloor = floor
                self.lifts[liftIndex].isMoving = false
                self.delegate?.liftDidArrive(lift: lift, floor: floor)
            }
        }
    }
}

