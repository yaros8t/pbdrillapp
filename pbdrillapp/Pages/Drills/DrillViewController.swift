//
//  ViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

final class DrillViewController: BaseDrillViewController {
    var drillModel: DrillModel!
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

    override func start() {
        super.start()
        service.start(with: drillModel)
    }

    override func stop() {
        super.stop()
        service.stop()

        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
    }
    
    override func startEditMode(_ view: TimeView) {
        super.startEditMode(view)
        
        if view == repeatsTimeView {
            timeLabel.text = "\(view.model?.value ?? 0)"
        }
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
}

extension DrillViewController: DrilTimerServiceDelegate {
    func drilTimerService(_: DrilTimerService, didUpdateDrill time: Int) {
        setTimeValue(time)
        pauseTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }

    func drilTimerService(_: DrilTimerService, didUpdatePause time: Int) {
        setTimeValue(time)
        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.pauseTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }

    func drilTimerService(_: DrilTimerService, didUpdateRepeats count: Int) {
        drillTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.repeatsTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }

        repeatsTimeView?.update(value: "\(count)")
    }

    func drilTimerServiceDidEnd() {
        stop()
    }
}

extension DrillViewController: RunButtonDelegate {
    func didChangeValue(_ value: Int) {
        guard let model = selectedTimeView?.model else { assert(false); return }
        
        selectedTime = model
        selectedTime?.value = value
        
        if selectedTimeView == repeatsTimeView {
            timeLabel.text = "\(value)"
        } else {
            setTimeValue(value)
        }
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
