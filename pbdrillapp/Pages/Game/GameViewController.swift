//
//  ViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

class GameViewController: BaseDrillViewController {
    private var gameModel: GameModel!
    private var waitTimeView: TimeView?
    private var limitTimeView: TimeView?

    private lazy var service: GameTimerService = GameTimerService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        gameModel = storage.getGameSettings()

        waitTimeView = addTimeView(with: gameModel.wait)
        limitTimeView = addTimeView(with: gameModel.limit)

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
        service.start(with: gameModel)
    }

    override func stop() {
        super.stop()
        service.stop()
        waitTimeView?.backgroundColor = .clear
    }

    private func save(_ time: TimeModel?) {
        guard let time = time else { assert(false); return }

        if time.id == gameModel.wait.id {
            gameModel.wait = time
            waitTimeView?.setup(model: time)
        } else if time.id == gameModel.limit.id {
            gameModel.limit = time
            limitTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        storage.save(settings: gameModel)

        hideTimeLabel()
    }
}

extension GameViewController: GameTimerServiceDelegate {
    func drilTimerService(_: GameTimerService, didUpdateGame time: Int) {
        setTimeValue(time)

        waitTimeView?.backgroundColor = .clear
    }

    func drilTimerService(_: GameTimerService, didUpdateWait time: Int) {
        setTimeValue(time)
        UIView.animate(withDuration: 0.3) {
            self.waitTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }

    func drilTimerServiceDidEnd() {
        super.stop()
        waitTimeView?.backgroundColor = .clear
    }
}

extension GameViewController: RunButtonDelegate {
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

