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
    func drilTimerService(_ service: DrilTimerService, didUpdateRepeat time: String)
}


final class DrilTimerService: NSObject {
    
    weak var delegate: DrilTimerServiceDelegate?
    
    private var drillTimer: Timer?
    private var pauseTimer: Timer?
    
    private lazy var synthesisVoice = AVSpeechSynthesisVoice(language: "ru")
    private lazy var synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    
    private var isRuned: Bool = false
    private var currentTimerValue: Int = 0
    private var currentRepeatsValue: Int = 0
    private var currentWaitValue: Int = 0
    
    private var model: DrillModel = .default
    
    init(delegate: DrilTimerServiceDelegate?) {
        super.init()
        
        self.delegate = delegate
    }
    
    func start(with model: DrillModel) {
        self.model = model
        currentTimerValue = model.total.value
        currentRepeatsValue = model.repeats.value
        currentWaitValue = model.pause.value
        
        startDrilTimer()
    }
    
    func stop() {
        
    }
    
    private func startPauseTimer() {
        pauseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentWaitValue > 1 {
                self.currentWaitValue -= 1
                self.delegate?.drilTimerService(self, didUpdatePause: "\(self.currentWaitValue)")
            } else {
                self.currentRepeatsValue -= 1
                self.delegate?.drilTimerService(self, didUpdateRepeat: "\(self.currentRepeatsValue)")

                self.resetWaitTimer()
                self.startDrilTimer()
            }
            })
        
        RunLoop.main.add(pauseTimer!, forMode: .common)
    }
    
    private func resetWaitTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil
        
//        currentWaitValue = settings.wait
//        updateWaitLabel()
    }
    
    private func startDrilTimer() {
        isRuned = true
        
        speech(text: "\(currentTimerValue)")
        
        drillTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentTimerValue > 1 {
                self.currentTimerValue -= 1
                self.delegate?.drilTimerService(self, didUpdateDril: "\(self.currentTimerValue)")

            } else if self.currentRepeatsValue == 1 {
                self.playSound(name: .startTrainig)
                self.resetAllTimers()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.playSound(name: .stopTrainig)
                }
            } else {
                self.playSound(name: .startTrainig)
                self.resetLimitTimer()
                self.startPauseTimer()
            }
        })
        
        RunLoop.main.add(drillTimer!, forMode: .common)
    }
    
    private func resetLimitTimer() {
        drillTimer?.invalidate()
        drillTimer = nil
        
        currentTimerValue = model.total.value
        delegate?.drilTimerService(self, didUpdateDril: "\(self.currentTimerValue)")
    }
    
    private func resetAllTimers() {
        isRuned = false

        resetLimitTimer()
        resetWaitTimer()
        model = .default
    }
    
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
}

extension DrilTimerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlayer()
    }
}
