import AVFoundation
import Foundation

protocol SoundAssistantServiceDelegate: class {
    func soundAssistantService(_ service: SoundAssistantService, didUpdateDrill time: Int)
    func soundAssistantService(_ service: SoundAssistantService, didUpdateRepeats time: Int)
    func soundAssistantServiceDidEnd()
}

protocol SoundAssistantServiceDataSource: class {
    func firstTags() -> [String]
    func secondTags() -> [String]
}

final class SoundAssistantService: NSObject {
    
    weak var delegate: SoundAssistantServiceDelegate?
    weak var dataSource: SoundAssistantServiceDataSource?

    private var drillTimer: Timer?

    private lazy var synthesisVoice = AVSpeechSynthesisVoice(language: Locale.current.languageCode)
    private lazy var synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    private var isRuned: Bool = false
    private var currentDrillValue: Int = 0
    private var currentRepeatsValue: Int = 0
    private var speechTextFirst: String = ""
    private var speechTextSecond: String = ""

    private var model: SoundAssistantModel = .default

    init(delegate: SoundAssistantServiceDelegate?, dataSource: SoundAssistantServiceDataSource?) {
        super.init()

        self.delegate = delegate
        self.dataSource = dataSource
        synthesizer.delegate = self
    }

    // MARK: -

    func start(with model: SoundAssistantModel) {
        isRuned = true
        setup(model: model)
        startDrillTimer()
    }

    func stop() {
        isRuned = false
        resetDrillTimer()
        stopAudioPlayer()
        resetValues()
        updateDrill()
        updateRepeats()
    }

    // MARK: -

    private func setup(model: SoundAssistantModel) {
        self.model = model
        currentDrillValue = model.drill.value
        currentRepeatsValue = model.repeats.value
    }

    // MARK: - Drill timer

    private func startDrillTimer() {
        guard isRuned else { return }
        
        updateDrill()

        drillTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }

            self.currentDrillValue -= 1
            self.updateDrill()

            if self.currentDrillValue == 0 && self.currentRepeatsValue > 0 {
                timer.invalidate()
                self.currentDrillValue = self.model.drill.value
                self.speechFirstTag()
                
                self.currentRepeatsValue -= 1
                self.updateRepeats()
            }
            
            if self.currentRepeatsValue == 0 {
                timer.invalidate()
                self.isRuned = false
                self.resetDrillTimer()
                self.resetValues()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.updateDrill()
                    self.updateRepeats()
                    
                    self.playSound(name: .stopTrainig)
                    self.delegate?.soundAssistantServiceDidEnd()
                }
            }
        })
    }

    private func resetDrillTimer() {
        drillTimer?.invalidate()
        drillTimer = nil
    }
    
    private func resetValues() {
        currentDrillValue = model.drill.value
        currentRepeatsValue = model.repeats.value
    }
    
    // MARK: - Tags
    
    private func speechFirstTag() {
        if let tags = dataSource?.firstTags() {
            let rand: Int = Int(arc4random_uniform(UInt32(tags.count)))
            speechTextFirst = tags[rand]
            speech(text: speechTextFirst)
        }
    }
    
    private func speechSecondTag() {
        if let tags = dataSource?.secondTags() {
            let rand = Int.random(in: 0...tags.count - 1)
            speechTextSecond = tags[rand]
            speech(text: speechTextSecond)
        }
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
        delegate?.soundAssistantService(self, didUpdateDrill: currentDrillValue)
    }

    private func updateRepeats() {
        delegate?.soundAssistantService(self, didUpdateRepeats: currentRepeatsValue)
    }
}

extension SoundAssistantService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        stopAudioPlayer()
    }
}

extension SoundAssistantService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if utterance.speechString == speechTextFirst {
            speechSecondTag()
        } else if utterance.speechString == speechTextSecond {
            startDrillTimer()
        }
    }
}
