import UIKit

final class RootViewController: UIViewController, SessionCommands {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var containerView: UIView!
    
    private lazy var storage: Storage = Storage()

    private var pagesViewController: PagesViewController? {
        didSet {
            pagesViewController?.pagesDelegate = self
        }
    }

    private lazy var drillControllers: [BaseDrillViewController] = {
        [initController("DrillViewController"),
         initController("GameViewController"),
         initController("SoundAssistantViewController"),
         initController("FeedbackViewController")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let training = storage.getDrillModel(type: .training)
        let game = storage.getDrillModel(type: .game)
        let rand = storage.getDrillModel(type: .rand)
        
        var trainingState = CommandStatus(command: .updateDrillTimerState, phrase: .sent)
        trainingState.model = training.dictionary
        var gameState = CommandStatus(command: .updateGameTimerState, phrase: .sent)
        gameState.model = game.dictionary
        var randState = CommandStatus(command: .updateSoundTimerState, phrase: .sent)
        randState.model = rand.dictionary
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        updateAppContext([DrillModelType.training.str + formatter.string(from: Date()): trainingState,
                          DrillModelType.game.str + formatter.string(from: Date()): gameState,
                          DrillModelType.rand.str + formatter.string(from: Date()): randState])
        
        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: .valueChanged)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let pagesViewController = segue.destination as? PagesViewController {
            self.pagesViewController = pagesViewController
            self.pagesViewController?.orderedViewControllers = drillControllers
        }
    }

    @IBAction func didTapNextButton(_: Any) {
        pagesViewController?.scrollToNextViewController()
    }

    @objc func didChangePageControlValue() {
        pagesViewController?.scrollToViewController(index: pageControl.currentPage)
    }

    private func initController(_ name: String) -> BaseDrillViewController {
        let base = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! BaseDrillViewController
        base.delegate = self
        return base
    }
}

extension RootViewController: PagesViewControllerDelegate {
    func pagesViewController(pagesViewController _: PagesViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func pagesViewController(pagesViewController _: PagesViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}

extension RootViewController: BaseDrillViewControllerDelegate {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = false
    }

    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode _: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = true
    }

    func drillViewControllerDidStartTimer() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = false
    }

    func drillViewControllerDidStopTimer() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = true
    }
}
