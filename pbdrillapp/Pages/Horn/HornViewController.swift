import UIKit
import AVFoundation

final class HornViewController: BaseDrillViewController {
    
    @IBOutlet private var playButton: UIButton!
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.backgroundColor = UIColor(named: "start")
    }
    
    @IBAction func didTapToHorn(_ sender: UIButton) {
        playSound(name: .startTrainig)
    }
    
    private func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}
