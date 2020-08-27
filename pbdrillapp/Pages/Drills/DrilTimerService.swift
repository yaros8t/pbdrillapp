//
//  DrilTimerService.swift
//  pbdrillapp
//
//  Created by Yaroslav Tytarenko on 24.08.2020.
//  Copyright © 2020 Yaros8T. All rights reserved.
//

import AVFoundation
import Foundation

protocol DrilTimerServiceDelegate: class {
    func drilTimerService(_ service: DrilTimerService, didUpdateDril time: Int)
    func drilTimerService(_ service: DrilTimerService, didUpdatePause time: Int)
    func drilTimerService(_ service: DrilTimerService, didUpdateRepeats count: Int)
    func drilTimerServiceDidEnd()
}

final class DrilTimerService: NSObject {
    weak var delegate: DrilTimerServiceDelegate?

    private var drillTimer: Timer?
    private var pauseTimer: Timer?

    private lazy var synthesisVoice = AVSpeechSynthesisVoice(language: "ru")
    private lazy var synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    private var isRuned: Bool = false
    private var currentDrillValue: Int = 0
    private var currentRepeatsValue: Int = 0
    private var currentPauseValue: Int = 0

    private var model: DrillModel = .default

    init(delegate: DrilTimerServiceDelegate?) {
        super.init()

        self.delegate = delegate
    }

    // MARK: -

    func start(with model: DrillModel) {
        setup(model: model)
        startPauseTimer()
    }

    func stop() {
        resetAllTimers()
        
        currentRepeatsValue = model.repeats.value
        updateRepeats()
    }

    // MARK: -

    private func setup(model: DrillModel) {
        self.model = model
        currentDrillValue = model.total.value
        currentRepeatsValue = model.repeats.value
        currentPauseValue = model.pause.value
    }

    // MARK: - Drill timer

    private func startDrillTimer() {
        updateDrill()

        drillTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            if self.currentDrillValue > 1 {
                self.currentDrillValue -= 1
                self.updateDrill()
            } else {
                if self.currentPauseValue == 0 {
                    self.playSound(name: .startTrainig)
                    self.currentRepeatsValue -= 1
                    self.updateRepeats()
                    
                    if self.currentRepeatsValue == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.playSound(name: .stopTrainig)
                        }
                        self.delegate?.drilTimerServiceDidEnd()
                    }
                }
                self.currentDrillValue -= 1
                self.updateDrill()
                self.resetDrillTimer()
                self.startPauseTimer()
            }
        })

        RunLoop.main.add(drillTimer!, forMode: .common)
    }

    private func resetDrillTimer() {
        drillTimer?.invalidate()
        drillTimer = nil
        currentDrillValue = model.total.value
    }

    // MARK: - Pause timer

    private func startPauseTimer() {
        isRuned = true

        if currentPauseValue != 0 {
            updatePause()
            speech(text: "\(currentPauseValue)")
            
                    pauseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                        guard let self = self else { return }

                        if self.currentPauseValue > 1 {
                            self.currentPauseValue -= 1
                            self.updatePause()

                        } else if self.currentRepeatsValue == 1 {
                            self.resetAllTimers()
                            self.updateRepeats()
                            self.playSound(name: .startTrainig)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.playSound(name: .stopTrainig)
                            }

                            self.delegate?.drilTimerServiceDidEnd()
                        } else {
                            self.currentRepeatsValue -= 1
                            self.updateRepeats()
                            self.playSound(name: .startTrainig)
                            self.resetPauseTimer()
                            self.startDrillTimer()
                        }
                    })
        } else {
            self.startDrillTimer()
        }
    }

    private func resetPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil

        currentPauseValue = model.pause.value
    }

    private func resetAllTimers() {
        isRuned = false
        setup(model: model)

        resetDrillTimer()
        resetPauseTimer()
    }

    // MARK: - Sounds

    private func speech(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = synthesisVoice
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }

    private func setupPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func stopAudioPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Delegates

    private func updateDrill() {
        delegate?.drilTimerService(self, didUpdateDril: currentDrillValue)
    }

    private func updatePause() {
        delegate?.drilTimerService(self, didUpdatePause: currentPauseValue)
    }

    private func updateRepeats() {
        delegate?.drilTimerService(self, didUpdateRepeats: currentRepeatsValue)
    }
}

extension DrilTimerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        stopAudioPlayer()
    }
}
