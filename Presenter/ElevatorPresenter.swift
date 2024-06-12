//
//  ElevatorPresenter.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import Foundation

protocol ElevatorPresenterProtocol {
    func loadConfig()
    func requestLift(toFloor floor: Int)
}

class ElevatorPresenter: ElevatorPresenterProtocol {
    
    weak var view: ElevatorViewController?
    var elevatorManager: ElevatorManager?
    
    init(view: ElevatorViewController) {
        self.view = view
    }
    
    func loadConfig() {
        JSONLoader.loadConfig(from: "https://demo0015790.mockable.io/") { [weak self] config in
            guard let config = config else {
                DispatchQueue.main.async {
                    self?.view?.showError(message: "Failed to load config")
                }
                return
            }
            
            if config.houseLevels > 20 || config.lifts.count > 4 || config.lifts.count < 2 {
                DispatchQueue.main.async {
                    self?.view?.showError(message: "Number of floors or elevators exceeds the allowed limit")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.elevatorManager = ElevatorManager(config: config)
                self?.elevatorManager?.delegate = self
                self?.view?.showElevators(config: config)
            }
        }
    }
    
    func requestLift(toFloor floor: Int) {
        guard let elevatorManager = elevatorManager else { return }
        elevatorManager.requestLift(toFloor: floor)
    }
    
    func liftDidArrive(lift: Elevator, floor: Int) {
        view?.updateElevatorPosition(lift: lift, floor: floor)
    }
    
    func liftWillArrive(lift: Elevator, floor: Int) {
        view?.willUpdateElevatorPosition(lift: lift, floor: floor)
    }
}
