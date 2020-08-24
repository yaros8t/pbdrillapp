//
//  ViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

final class DrillViewController: BaseDrillViewController {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var runButton: RunButton!
    
    private lazy var storage: Storage = Storage()
    private var drillModel: DrillModel!
    
    private var selectedTimeView: TimeView?
    private var selectedTime: TimeModel?
    
    private var drillTimeView: TimeView?
    private var pauseTimeView: TimeView?
    private var repeatsTimeView: TimeView?
    
    private lazy var service: DrilTimerService = DrilTimerService(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        drillModel = storage.getDrillModel()
        
        drillTimeView = addTimeView(with: drillModel.total)
        pauseTimeView = addTimeView(with: drillModel.pause)
        repeatsTimeView = addTimeView(with: drillModel.repeats)

        hideTimeLabel()
        runButton.delegate = self
    }
    
    override func changeMode(_ mode: BaseDrillViewController.Mode) {
        guard self.mode != mode else { return }
        
        self.mode = mode
        
        if mode == .edit {
            startEditMode(selectedTimeView!)
            delegate?.drillViewController(self, didStartEditMode: selectedTimeView!.model!)
        } else {
            endEditMode()
            delegate?.drillViewController(self, didEndEditMode: selectedTimeView!.model!)
        }
    }
    
    override func applyNewValue() {
        save(selectedTime)
        changeMode(.regular)
    }
    
    override func cancelNewValue() {
        selectedTime = nil
        changeMode(.regular)
    }
    
    private func addTimeView(with model: TimeModel) -> TimeView {
        let timeView = TimeView()
        timeView.delegate = self
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.heightAnchor.constraint(equalToConstant: 53).isActive = true
        timeView.setup(model: model)
        timeView.setupRegularMode(animated: false)
        stackView.addArrangedSubview(timeView)
        
        return timeView
    }
    
    private func startEditMode(_ view: TimeView) {
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
    
    private func endEditMode() {
        (stackView.arrangedSubviews as! [TimeView]).forEach {
            $0.setupRegularMode()
            $0.setActive(true)
            $0.setButtonActive(false)
        }
        
        runButton.setupStopMode()
        
        hideTimeLabel()
    }
    
    private func save(_ time: TimeModel?) {
        guard let time = time else { assert(false); return }
        
        if time.id == drillModel.pause.id {
            drillModel.pause = time
            pauseTimeView?.setup(model: time)
        } else if time.id == drillModel.total.id {
            drillModel.total = time
            drillTimeView?.setup(model: time)
        } else if time.id == drillModel.repeats.id {
            drillModel.repeats = time
            repeatsTimeView?.setup(model: time)
        } else {
            assert(false)
        }
         
        storage.save(settings: drillModel)
        
        hideTimeLabel()
    }
    
    //MARK: - Time Label
    private func showTimeLabel() {
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 1
        }
    }
    
    private func hideTimeLabel() {
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 0
        }
    }
    
    private func setTimeValue(_ value: Int) {
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

extension DrillViewController: TimeViewDelegate {
    
    func timeView(_ view: TimeView, didSelect: Bool) {
        selectedTimeView = view
        
        if mode == .edit, selectedTimeView == view {
            changeMode(.regular)
        } else {
            changeMode(.edit)
        }
    }
}

extension DrillViewController: RunButtonDelegate {
    
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
    
    private func start() {
        isRunned = true
        runButton.setupStartMode()
        delegate?.drillViewController(self, didStartTimer: drillModel)
        
        showTimeLabel()
        
        service.start(with: drillModel)
    }
    
    private func stop() {
        isRunned = false
        runButton.setupStopMode()
        delegate?.drillViewController(self, didStopTimer: drillModel)
        service.stop()
        hideTimeLabel()
    }
}

extension DrillViewController: DrilTimerServiceDelegate {
    
    func drilTimerService(_ service: DrilTimerService, didUpdateDril time: Int) {
        setTimeValue(time)
        pauseTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }
    
    func drilTimerService(_ service: DrilTimerService, didUpdatePause time: Int) {
        setTimeValue(time)
        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.pauseTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }
    
    func drilTimerService(_ service: DrilTimerService, didUpdateRepeats count: Int) {
        drillTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.repeatsTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
        
        repeatsTimeView?.update(value: "\(count)")
    }
    
    func drilTimerServiceDidEnd() {
        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        stop()
    }
}
