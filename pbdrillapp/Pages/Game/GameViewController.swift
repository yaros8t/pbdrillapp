//
//  ViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

class GameViewController: BaseDrillViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var runButton: RunButton!
    
//    private lazy var storage: Storage = Storage()
//    private var drillModel: DrillModel { storage.getDrillModel() }
//
//    private var selectedTimeView: TimeView?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        drillModel.options.forEach {
//            addTimeView(with: $0)
//        }
//
//        timeLabel.alpha = 0
//    }
//
//    override func changeMode(_ mode: BaseDrillViewController.Mode) {
//        guard self.mode != mode else { return }
//
//        self.mode = mode
//
//        if mode == .edit {
//            startEditMode(selectedTimeView!)
//            delegate?.drillViewController(self, didStartEditMode: selectedTimeView!.model!)
//        } else {
//            endEditMode()
//            delegate?.drillViewController(self, didEndEditMode: selectedTimeView!.model!)
//        }
//    }
//
//    override func applyNewValue() {
//         changeMode(.regular)
//    }
//
//    override func cancelNewValue() {
//        changeMode(.regular)
//    }
//
//    private func addTimeView(with model: TimeModel) {
//        let timeView = TimeView()
//        timeView.delegate = self
//        timeView.translatesAutoresizingMaskIntoConstraints = false
//        timeView.heightAnchor.constraint(equalToConstant: 53).isActive = true
//        timeView.setup(model: model)
//        timeView.setupRegularMode(animated: false)
//        stackView.addArrangedSubview(timeView)
//    }
//
//    private func startEditMode(_ view: TimeView) {
//        (stackView.arrangedSubviews as! [TimeView]).forEach {
//            $0.setupEditMode()
//            $0.setActive($0 == view)
//            $0.setButtonActive($0 == view)
//        }
//
//        runButton.setupSliderMode()
//
//        UIView.animate(withDuration: 0.3) {
//            self.timeLabel.alpha = 1
//        }
//    }
//
//    private func endEditMode() {
//        (stackView.arrangedSubviews as! [TimeView]).forEach {
//            $0.setupRegularMode()
//            $0.setActive(true)
//            $0.setButtonActive(false)
//        }
//
//        runButton.setupStopMode()
//
//        UIView.animate(withDuration: 0.3) {
//            self.timeLabel.alpha = 0
//        }
//    }
}

//extension GameViewController: TimeViewDelegate {
//    func timeView(_ view: TimeView, didSelect: Bool) {
//        selectedTimeView = view
//
//        if mode == .edit, selectedTimeView == view {
//            changeMode(.regular)
//        } else {
//            changeMode(.edit)
//        }
//    }
//}
