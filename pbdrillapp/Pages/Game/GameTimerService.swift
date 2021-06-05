import AVFoundation
import Foundation

protocol GameTimerServiceDelegate: class {
    func drilTimerService(_ service: GameTimerService, didUpdateGame time: Int)
    func drilTimerService(_ service: GameTimerService, didUpdateWait time: Int)
    func drilTimerServiceDidEnd()
}

final class GameTimerService: NSObject {
    weak var delegate: GameTimerServiceDelegate?

    private var gameTimer: Timer?
    private var waitTimer: Timer?

    private lazy var synthesisVoice = AVSpeechSynthesisVoice(language: "en")
    private lazy var synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    private var isRuned: Bool = false
    private var currentGameValue: Int = 0
    private var currentWaitValue: Int = 0
    private var currentLimitValue: Int = 0

    private var model: GameModel = .default

    init(delegate: GameTimerServiceDelegate?) {
        super.init()

        self.delegate = delegate
    }

    // MARK: -

    func start(with model: GameModel) {
        setup(model: model)
        startWaitTimer()
    }

    func stop() {
        resetAllTimers()
        playSound(name: .stopGame)
    }

    // MARK: -

    private func setup(model: GameModel) {
        self.model = model
        currentGameValue = 0
        currentWaitValue = model.wait.value
        currentLimitValue = model.limit.value
    }

    // MARK: - Drill timer

    private func startGameTimer() {
        updateGame()
        resetWaitTimer()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            self.currentGameValue += 1
            self.updateGame()

            if self.currentLimitValue > 0, self.currentGameValue >= self.currentLimitValue {
                self.playSound(name: .stopGame)
                self.resetAllTimers()
                self.delegate?.drilTimerServiceDidEnd()
            }
        })

        RunLoop.main.add(gameTimer!, forMode: .common)
    }

    private func resetGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
        currentGameValue = 0
    }

    // MARK: - Pause timer

    private func startWaitTimer() {
        isRuned = true

        updateWait()
        speech(text: "\(currentWaitValue)")

        waitTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            self.currentWaitValue -= 1
            self.updateWait()

            if self.currentWaitValue == 61 {
                self.speech(text: "\(self.currentWaitValue - 1) seconds")
            } else if self.currentWaitValue == 46 {
                self.speech(text: "\(self.currentWaitValue - 1) seconds")
            } else if self.currentWaitValue == 31 {
                self.speech(text: "\(self.currentWaitValue - 1) seconds")
            } else if self.currentWaitValue == 16 {
                self.speech(text: "\(self.currentWaitValue - 1) seconds")
            } else if self.currentWaitValue == 11 {
                self.playSound(name: .tenSeconds)
            } else if self.currentWaitValue == 0 {
                self.playSound(name: .startGame)
                self.startGameTimer()
            }
        })

        RunLoop.main.add(waitTimer!, forMode: .common)
    }

    private func resetWaitTimer() {
        waitTimer?.invalidate()
        waitTimer = nil

        currentWaitValue = model.wait.value
    }

    private func resetAllTimers() {
        isRuned = false
        setup(model: model)

        resetGameTimer()
        resetWaitTimer()
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

    private func updateGame() {
        delegate?.drilTimerService(self, didUpdateGame: currentGameValue)
    }

    private func updateWait() {
        delegate?.drilTimerService(self, didUpdateWait: currentWaitValue)
    }
}

extension GameTimerService: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        stopAudioPlayer()
    }
}
