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

        timeLabel.alpha = 0
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
        
        (stackView.arrangedSubviews as! [TimeView]).forEach {
            $0.setupEditMode()
            $0.setActive($0 == view)
            $0.setButtonActive($0 == view)
        }
        
        runButton.setupSliderMode(animated: true, range: model.range)
        
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 1
        }
    }
    
    private func endEditMode() {
        (stackView.arrangedSubviews as! [TimeView]).forEach {
            $0.setupRegularMode()
            $0.setActive(true)
            $0.setButtonActive(false)
        }
        
        runButton.setupStopMode()
        
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 0
        }
    }
    
    private func save(_ time: TimeModel?) {
//        guard let time = time else { assert(false); return }
//        guard let index = drillModel.options.firstIndex(of: time) else { assert(false); return }
//
//        drillModel.options.remove(at: index)
//        drillModel.options.insert(time, at: index)
//        storage.save(settings: drillModel)
    }
    
//    // Timers
//    private func start() {
//        runButton.setupStartMode()
//        delegate?.drillViewController(self, didStartTimer: drillModel)
//
//    }
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
        timeLabel.text = "\(value)"
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
        
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 1
        }
        
        service.start(with: drillModel)
    }
    
    private func stop() {
        isRunned = false
        runButton.setupStopMode()
        delegate?.drillViewController(self, didStopTimer: drillModel)
        service.stop()
        timeLabel.text = ""
        UIView.animate(withDuration: 0.3) {
            self.timeLabel.alpha = 0
        }
    }
}

extension DrillViewController: DrilTimerServiceDelegate {
    
    func drilTimerService(_ service: DrilTimerService, didUpdateDril time: String) {
        timeLabel.text = time
        pauseTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }
    
    func drilTimerService(_ service: DrilTimerService, didUpdatePause time: String) {
        timeLabel.text = time
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
