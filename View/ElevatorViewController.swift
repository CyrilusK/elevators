//
//  ElevatorViewController.swift
//  Elevators
//
//  Created by Cyril Kardash on 03.06.2024.
//

import UIKit

protocol ElevatorView: AnyObject {
    func updateElevatorPosition(id: Int, floor: Int)
    func showError(message: String)
    func showElevators(config: BuildingConfig)
}

class ElevatorViewController: UIViewController, ElevatorView {
    private var buildingConfig: BuildingConfig?
    private var presenter: ElevatorPresenter!
    
    // Словарь для хранения связей между кнопкой вызова и лифтами
    var buttonPairs: [Int: (callButton: UIButton, elevatorButtons: [UIButton])] = [:]
    
    func updateElevatorPosition(id: Int, floor: Int) {
        print("Elevator \(id) arrived at floor \(floor)")
        self.animateElevator(id: id, at: floor)
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
            buttonForCall.tintColor = .blue
            buttonForCall.addTarget(self, action: #selector(callFromBtn), for: .touchUpInside)
            floorsStack.addArrangedSubview(buttonForCall)

            for lift in buildingConfig.lifts {
                let elevators = UIButton(type: .system)
                elevators.backgroundColor = .orange
                elevators.tag = lift.id
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
        guard let floor = Int(sender.currentTitle ?? "") else { return }
        presenter.requestLift(toFloor: floor)
    }
    
    @objc func callFromBtn(_ sender: UIButton) {
        let floor = Int(sender.tag)
        presenter.requestLift(toFloor: floor)
    }
    
    func animateElevator(id lift: Int, at floor: Int) {
        guard let buildingConfig = buildingConfig else { return }
        
        if let buttonPair = buttonPairs[floor] {
            let elevatorButtons = buttonPair.elevatorButtons
            for elevatorButton in elevatorButtons where (lift == elevatorButton.tag) {
                // Открытие дверей
                DispatchQueue.main.async {
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
                            }
                        }
                    }
                }
            }
        }
    }
}
