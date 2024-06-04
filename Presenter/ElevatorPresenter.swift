//
//  ElevatorPresenter.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import Foundation

class ElevatorPresenter {
    weak var view: ElevatorViewController?
    
    init(view: ElevatorViewController) {
        self.view = view
    }
    
    func loadConfig() {
        JSONLoader.loadConfig(from: "https://demo0015790.mockable.io/") { [weak self] config in
            guard let config = config else { return }
            DispatchQueue.main.async {
                self?.view?.showElevators(config: config)
            }
        }
    }
    
    func callElevator(to floor: Int) {
        // Логика вызова лифта
    }
}
