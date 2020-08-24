//
//  DrilTimerService.swift
//  pbdrillapp
//
//  Created by Yaroslav Tytarenko on 24.08.2020.
//  Copyright © 2020 Yaros8T. All rights reserved.
//

import Foundation
import AVFoundation


protocol DrilTimerServiceDelegate: class {
    func drilTimerService(_ service: DrilTimerService, didUpdateDril time: String)
    func drilTimerService(_ service: DrilTimerService, didUpdatePause time: String)
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
    
    //MARK: -
    func start(with model: DrillModel) {
        setup(model: model)
        startPauseTimer()
    }
    
    func stop() {
        resetAllTimers()
    }
    
    //MARK: -
    private func setup(model: DrillModel) {
        self.model = model
        currentDrillValue = model.total.value
        currentRepeatsValue = model.repeats.value
        currentPauseValue = model.pause.value
    }
    
    //MARK: - Drill timer
    
    private func startDrillTimer() {
        updateDrill()
        
        drillTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentDrillValue > 1 {
                self.currentDrillValue -= 1
                self.updateDrill()
            } else {
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
    
    //MARK: - Pause timer
    
    private func startPauseTimer() {
        isRuned = true
        
        updatePause()
        speech(text: "\(currentPauseValue)")
        
        pauseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentPauseValue > 1 {
                self.currentPauseValue -= 1
                self.updatePause()

            } else if self.currentRepeatsValue == 1 {
                self.playSound(name: .startTrainig)
                self.resetAllTimers()
                self.updateRepeats()

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
        
        RunLoop.main.add(pauseTimer!, forMode: .common)
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
    
    //MARK: - Sounds
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
    
    //MARK: - Delegates
    private func updateDrill() {
        let time = secondsToHoursMinutesSeconds(interval: currentDrillValue)
        delegate?.drilTimerService(self, didUpdateDril: time)
    }
    
    private func updatePause() {
        let time = secondsToHoursMinutesSeconds(interval: currentPauseValue)
        delegate?.drilTimerService(self, didUpdatePause: time)
    }
    
    private func updateRepeats() {
        delegate?.drilTimerService(self, didUpdateRepeats: currentRepeatsValue)
    }
    
    //MARK: - Utils
    private func secondsToHoursMinutesSeconds(interval : Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(interval))!
    }
}

extension DrilTimerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlayer()
    }
}
