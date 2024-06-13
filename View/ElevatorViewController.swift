//
//  ElevatorViewController.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import UIKit

protocol ElevatorView: AnyObject {
    func updateElevatorPosition(lift: Elevator, floor: Int)
    func showError(message: String)
    func showElevators(config: BuildingConfig)
}

class ElevatorViewController: UIViewController, ElevatorView {
    private var buildingConfig: BuildingConfig?
    private var presenter: ElevatorPresenter!
    
    var buttonForLifts: [Int: UIButton] = [:]
    var buttonPressed: [UIButton: Bool] = [:]
    var elevators: [Int: [UILabel]] = [:]
    let mainStack = UIStackView()
    
    func updateElevatorPosition(lift: Elevator, floor: Int) {
        print("Elevator \(lift.id) arrived at floor \(floor)")
        self.openCloseElevator(lift: lift, at: floor)
        if let callButton = buttonForLifts[floor] {
            buttonPressed[callButton] = false
            //callButton.isEnabled = true
        }
        print(#function)
    }
    
    func willUpdateElevatorPosition(lift: Elevator, floor: Int) {
        if let callButton = buttonForLifts[floor] {
            callButton.isEnabled = false
        }
        self.animateElevator(lift: lift, toFloor: floor)
        print(#function)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ElevatorPresenter(view: self)
        presenter.loadConfig()
        print(#function)
    }
    
    func showElevators(config: BuildingConfig) {
        self.buildingConfig = config
        setupUI()
        print(#function)
    }
    
    func setupUI() {
        guard let buildingConfig = buildingConfig else { return }
        
        view.backgroundColor = .systemBackground
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

            let callButton = UIButton(type: .system)
            let btnImage = UIImage(systemName: "record.circle")
            callButton.setImage(btnImage, for: .normal)
            callButton.imageView?.contentMode = .scaleAspectFit
            callButton.tag = floor
            callButton.tintColor = .blue
            callButton.addTarget(self, action: #selector(callFromBtn), for: .touchUpInside)
            floorsStack.addArrangedSubview(callButton)
            
            buttonPressed[callButton] = false
            buttonForLifts[floor] = callButton
            
            var floorElevatorImages: [UILabel] = []

            for lift in buildingConfig.lifts {
                let elevator = UILabel()
                elevator.backgroundColor = .orange
                elevator.text = String(floor)
                elevator.textAlignment = .center
                elevator.tag = lift.id
                floorsStack.addArrangedSubview(elevator)
                floorElevatorImages.append(elevator)
                
            }
            elevators[floor] = floorElevatorImages
            mainStack.addArrangedSubview(floorsStack)
        }
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        mainStack.layoutIfNeeded()
    }
    
    @objc func callFromBtn(_ sender: UIButton) {
        let floor = Int(sender.tag)
        if (!buttonPressed[sender]!) {
            presenter.requestLift(toFloor: floor)
            buttonPressed[sender] = true
        }
        print(#function)
    }
    
    func openCloseElevator(lift elevator: Elevator, at floor: Int) {
        guard let buildingConfig = buildingConfig else { return }
        
        if let floorElevators = elevators[floor] {
            for floorElevator in floorElevators where (elevator.id == floorElevator.tag) {
                // Открытие дверей
                UIView.transition(with: floorElevator, duration: TimeInterval(buildingConfig.timeOpenCloseDoor), options: .transitionCrossDissolve, animations: {
                    floorElevator.backgroundColor = .white
                    floorElevator.text = "Opening"
                }, completion: { _ in
                    floorElevator.text = "Open"
                    // Пауза с открытыми дверями
                    DispatchQueue.main.asyncAfter(deadline: .now() + buildingConfig.timeOpenCloseDoor)  {
                        // Закрытие дверей
                        UIView.transition(with: floorElevator, duration: TimeInterval(buildingConfig.timeOpenCloseDoor), options: .transitionCrossDissolve, animations: {
                            floorElevator.backgroundColor = .orange
                            floorElevator.text = "Closing"
                        }, completion: { _ in
                            // Завершение закрытия дверей
                            floorElevator.text = String(floor)
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + buildingConfig.timeOpenCloseDoor)  {
                            if let callButton = self.buttonForLifts[floor] {
                                callButton.isEnabled = true
                            }
                        }
                    }
                })
            }
        }
        print(#function)
    }
    
    func animateElevator(lift elevator: Elevator, toFloor: Int) {
        guard let buildingConfig = buildingConfig else { return }
        
        if let floorElevators = elevators[elevator.currentFloor], let elevatorLabel = floorElevators.first(where: { $0.tag == elevator.id }) {
            
            let floorHeight = elevatorLabel.bounds.height + 10
            let fromFloor = elevator.currentFloor
            let deltaY = CGFloat(Double(floorHeight) * Double(abs(toFloor - fromFloor)))
            let temporaryElevatorLabel = UILabel(frame: elevatorLabel.frame)
            
            temporaryElevatorLabel.frame.origin.x += 10
            temporaryElevatorLabel.frame.origin.y = mainStack.bounds.height + view.safeAreaInsets.top + 20 - CGFloat(fromFloor) * (floorHeight)
            print(deltaY)
            temporaryElevatorLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
            view.addSubview(temporaryElevatorLabel)
                    
            UIView.animate(withDuration: TimeInterval(buildingConfig.timeToElevate * Double(abs(elevator.currentFloor - toFloor)) + 0.65), animations: {
                if fromFloor > toFloor {
                    temporaryElevatorLabel.frame.origin.y += deltaY
                } else {
                    temporaryElevatorLabel.frame.origin.y -= deltaY
                }
            }) { _ in
                print(temporaryElevatorLabel.frame)
                temporaryElevatorLabel.removeFromSuperview()
            }
        }
        print(#function)
    }

}
