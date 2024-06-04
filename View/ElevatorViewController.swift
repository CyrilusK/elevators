//
//  ElevatorViewController.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import UIKit

class ElevatorViewController: UIViewController {

    private var presenter: ElevatorPresenter!
    private var buildingConfig: BuildingConfig!
    
    // Словарь для хранения связей между кнопкой вызова и лифтами
    var buttonPairs: [Int: (callButton: UIButton, elevatorButtons: [UIButton])] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ElevatorPresenter(view: self)
        presenter.loadConfig()
    }

    func showElevators(config: BuildingConfig) {
        self.buildingConfig = config
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fillEqually
        mainStack.spacing = 10

        for floor in (1...buildingConfig.houseLevels).reversed() {
            let floorsStack = UIStackView()
            floorsStack.axis = .horizontal
            floorsStack.alignment = .fill
            floorsStack.distribution = .fillEqually
            floorsStack.spacing = 10
            
            var elevatorButtons: [UIButton] = []
            
            let buttonForCall = UIButton(type: .system)
            let btnImage = UIImage(systemName: "chevron.up.chevron.down")
            buttonForCall.setImage(btnImage, for: .normal)
            buttonForCall.imageView?.contentMode = .scaleAspectFit
            buttonForCall.tag = floor
            buttonForCall.addTarget(self, action: #selector(callElevator), for: .touchUpInside)
            floorsStack.addArrangedSubview(buttonForCall)
            
            for _ in 1...buildingConfig.lifts.count {
                let elevators = UIButton(type: .system)
                elevators.backgroundColor = .orange
                elevators.tag = floor
                elevators.setTitle("\(floor)", for: .normal)
                elevators.addTarget(self, action: #selector(callElevator), for: .touchUpInside)
                floorsStack.addArrangedSubview(elevators)
                elevatorButtons.append(elevators)
            }
            buttonPairs[floor] = (callButton: buttonForCall, elevatorButtons: elevatorButtons)
            
            mainStack.addArrangedSubview(floorsStack)
        }
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func callElevator(_ sender: UIButton) {
        let floor = sender.tag
        presenter.callElevator(to: floor)
        
        for i in stride(from: 1, through: floor, by: 1) {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.buildingConfig.timeToElevate * Double(i - 1)) {
                if floor == i {
                    self.animateElevator(at: i)
                }
            }
        }
    }
    
    func animateElevator(at floor: Int) {
        if let buttonPair = buttonPairs[floor] {
            let elevatorButtons = buttonPair.elevatorButtons
            for elevatorButton in elevatorButtons {
                UIView.animate(withDuration: self.buildingConfig.timeOpenCloseDoor) {
                    elevatorButton.backgroundColor = .lightGray
                    elevatorButton.setTitle("Open", for: .normal)
                    UIView.animate(withDuration: self.buildingConfig.timeOpenCloseDoor, delay: self.buildingConfig.timeOpenCloseDoor) {
                        elevatorButton.backgroundColor = .orange
                        elevatorButton.setTitle("\(floor)", for: .normal)
                    }
                }
            }
        }
    }
}
