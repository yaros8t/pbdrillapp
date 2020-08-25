//
//  BaseDrillViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 11.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

protocol BaseDrillViewControllerDelegate: class {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel)
    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode model: TimeModel)
    
    func drillViewControllerDidStartTimer()
    func drillViewControllerDidStopTimer()
}

class BaseDrillViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var runButton: RunButton!

    weak var delegate: BaseDrillViewControllerDelegate?
    var mode: Mode = .regular
    var isRunned: Bool = false
    
    lazy var storage: Storage = Storage()
    
    var selectedTimeView: TimeView?
    var selectedTime: TimeModel?
    
    enum Mode {
        case regular
        case edit
    }
    
    func changeMode(_ mode: Mode) {
    }
    
    func applyNewValue() {}
    
    func cancelNewValue() {}
    
    func addTimeView(with model: TimeModel) -> TimeView {
        let timeView = TimeView()
        timeView.delegate = self
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.heightAnchor.constraint(equalToConstant: 53).isActive = true
        timeView.setup(model: model)
        timeView.setupRegularMode(animated: false)
        stackView.addArrangedSubview(timeView)
        
        return timeView
    }
    
    func startEditMode(_ view: TimeView) {
        guard let model = view.model else { assert(false); return }
        
        showTimeLabel()
        setTimeValue(model.value)
        
        (stackView.arrangedSubviews as! [TimeView]).forEach {
            $0.setupEditMode()
            $0.setActive($0 == view)
            $0.setButtonActive($0 == view)
        }
        
        runButton.setupSliderMode(animated: true, range: model.range, value: model.value)
    }
    
    func endEditMode() {
        (stackView.arrangedSubviews as! [TimeView]).forEach {
            $0.setupRegularMode()
            $0.setActive(true)
            $0.setButtonActive(false)
        }
        
        runButton.setupStopMode()
        
        hideTimeLabel()
    }
    
    func start() {
        isRunned = true
        runButton.setupStartMode()
        delegate?.drillViewControllerDidStartTimer()
        
        showTimeLabel()
    }
    
    func stop() {
        isRunned = false
        runButton.setupStopMode()
        delegate?.drillViewControllerDidStopTimer()
        hideTimeLabel()
    }
    
    //MARK: - Time Label
    func showTimeLabel() {
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 1
        }
    }
    
    func hideTimeLabel() {
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 0
        }
    }
    
    func setTimeValue(_ value: Int) {
        timeLabel.text = secondsToHoursMinutesSeconds(interval: value)
    }
    
    //MARK: - Utils
    private func secondsToHoursMinutesSeconds(interval : Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(interval))!
    }
}

extension BaseDrillViewController: TimeViewDelegate {
    
    func timeView(_ view: TimeView, didSelect: Bool) {
        selectedTimeView = view
        
        if mode == .edit, selectedTimeView == view {
            changeMode(.regular)
        } else {
            changeMode(.edit)
        }
    }
}

extension BaseDrillViewController: RunButtonDelegate {
    
    func didChangeValue(_ value: Int) {
        guard let model = selectedTimeView?.model else { assert(false); return }
        selectedTime = model
        selectedTime?.value = value
        setTimeValue(value)
    }
    
    func runButtonDidTap() {
        guard mode != .edit else { return }
        
        if isRunned {
            stop()
        } else {
            start()
        }
    }
}
