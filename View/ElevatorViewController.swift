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
    
    private let imageUp = UIImageView(image: UIImage(systemName: "arrow.up"))
    let imageDown = UIImageView(image: UIImage(systemName: "arrow.down"))
    
    // Словарь для хранения связей между кнопкой вызова и лифтами
    var buttonPairs: [Int: (callButton: UIButton, elevatorButtons: [UIButton])] = [:]
    var buttonPressed: [UIButton: Bool] = [:]
    var elevatorAnimating: Bool = false
    
    func updateElevatorPosition(lift: Elevator, floor: Int) {
        print("Elevator \(lift.id) arrived at floor \(floor)")
        self.animateElevator(lift: lift, at: floor)
        
        if let buttonPair = buttonPairs[floor] {
            buttonPressed[buttonPair.callButton] = false
        }
    }
    
    func willUpdateElevatorPosition(lift: Elevator, floor: Int) {
        if (lift.currentFloor - floor < 0) {
            imageUp.tintColor = .green
        }
        else {
            imageDown.tintColor = .green
        }
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
    }
    
    func showElevators(config: BuildingConfig) {
        self.buildingConfig = config
        setupUI()
    }
    
    func setupUI() {
        guard let buildingConfig = buildingConfig else { return }
        
        view.backgroundColor = .systemBackground
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fillEqually
        mainStack.spacing = 10
        
        imageUp.tintColor = .blue
        imageUp.contentMode = .scaleAspectFit
        view.addSubview(imageUp)
        
        imageDown.tintColor = .blue
        imageDown.contentMode = .scaleAspectFit
        view.addSubview(imageDown)
        
        imageUp.translatesAutoresizingMaskIntoConstraints = false
        imageDown.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageUp.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageDown.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageDown.leadingAnchor.constraint(equalTo: imageUp.trailingAnchor),
            imageUp.heightAnchor.constraint(equalToConstant: 50),
            imageDown.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        for floor in (1...buildingConfig.houseLevels).reversed() {
            let floorsStack = UIStackView()
            floorsStack.axis = .horizontal
            floorsStack.alignment = .fill
            floorsStack.distribution = .fillEqually
            floorsStack.spacing = 10

            var elevatorButtons: [UIButton] = []

            let buttonForCall = UIButton(type: .system)
            let btnImage = UIImage(systemName: "record.circle")
            buttonForCall.setImage(btnImage, for: .normal)
            buttonForCall.imageView?.contentMode = .scaleAspectFit
            buttonForCall.tag = floor
            buttonForCall.tintColor = .blue
            buttonForCall.addTarget(self, action: #selector(callFromBtn), for: .touchUpInside)
            floorsStack.addArrangedSubview(buttonForCall)
            
            buttonPressed[buttonForCall] = false

            for lift in buildingConfig.lifts {
                let elevators = UIButton(type: .system)
                elevators.backgroundColor = .orange
                elevators.tag = lift.id
                elevators.setTitle("\(floor)", for: .normal)
                elevators.addTarget(self, action: #selector(callElevator), for: .touchUpInside)
                floorsStack.addArrangedSubview(elevators)
                elevatorButtons.append(elevators)
                
                buttonPressed[elevators] = false
            }
            buttonPairs[floor] = (callButton: buttonForCall, elevatorButtons: elevatorButtons)

            mainStack.addArrangedSubview(floorsStack)
        }
        
        view.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: imageUp.bottomAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func callElevator(_ sender: UIButton) {
        guard let floor = Int(sender.currentTitle ?? "") else { return }
        if (!buttonPressed[sender]! && !elevatorAnimating) {
            presenter.requestLift(toFloor: floor)
            buttonPressed[sender] = true
            sender.isEnabled = false
        }
    }
    
    @objc func callFromBtn(_ sender: UIButton) {
        let floor = Int(sender.tag)
        if (!buttonPressed[sender]! && !elevatorAnimating) {
            presenter.requestLift(toFloor: floor)
            buttonPressed[sender] = true
            sender.isEnabled = false
        }
    }
    
    func animateElevator(lift elevator: Elevator, at floor: Int) {
        guard let buildingConfig = buildingConfig else { return }
        
        if let buttonPair = buttonPairs[floor] {
            let elevatorButtons = buttonPair.elevatorButtons
            for elevatorButton in elevatorButtons where (elevator.id == elevatorButton.tag) {
                elevatorAnimating = true
                // Открытие дверей
                elevatorButton.isEnabled = false
                    UIView.animate(withDuration: TimeInterval(buildingConfig.timeOpenCloseDoor), animations: {
                        elevatorButton.backgroundColor = .white
                        elevatorButton.setTitle("Opening", for: .normal)
                    }) { _ in
                        elevatorButton.setTitle("Open", for: .normal)
                        // Пауза с открытыми дверями
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(buildingConfig.timeOpenCloseDoor)) {
                            // Закрытие дверей
                            UIView.animate(withDuration: TimeInterval(buildingConfig.timeOpenCloseDoor), animations: {
                                elevatorButton.backgroundColor = .orange
                                elevatorButton.setTitle("Closing", for: .normal)
                            }) { _ in
                                // Завершение закрытия дверей
                                elevatorButton.setTitle("\(floor)", for: .normal)
                                elevatorButton.isEnabled = true
                                self.elevatorAnimating = false
                            }
                        }
                    }
            }
            buttonPair.callButton.isEnabled = true
            if (!elevator.isMoving) {
                imageUp.tintColor = .blue
                imageDown.tintColor = .blue
            }
        }
    }
}
