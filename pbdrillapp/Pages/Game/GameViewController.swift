import UIKit

final class GameViewController: BaseDrillViewController {
    
    private var model: DrillModel!
    private var waitTimeView: TimeView?
    private var limitTimeView: TimeView?

    private lazy var service: GameTimerService = GameTimerService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        model = storage.getDrillModel(type: .game)

        waitTimeView = addTimeView(with: model.gameWait)
        limitTimeView = addTimeView(with: model.gameLimit)
        
        updateGameTimerState(model.dictionary)
        
        resetTimeLabel()
    }

    override func start() {
        resetTimeViews()
        super.start()
        service.start(with: model)
    }

    override func stop() {
        super.stop()
        service.stop()
        waitTimeView?.backgroundColor = .clear
        resetTimeLabel()
    }

    override func save(_ time: TimeModel?) {
        guard let time = time else { assert(false); return }

        if time.type == .gameWait {
            waitTimeView?.setup(model: time)
        } else if time.type == .gameLimit {
            limitTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        model.update(time)
        storage.save(settings: model)
    }
    
    private func resetTimeViews() {
        waitTimeView?.setupRegularMode()
        limitTimeView?.setupRegularMode()
        timeView(waitTimeView!, didSelect: false)
        timeView(limitTimeView!, didSelect: false)
    }
    
    private func resetTimeLabel() {
        timeLabel.text = "\(model.gameWait.value)s"
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
            self.waitTimeView?.backgroundColor = UIColor(named: "timeHighlight")
        }
    }

    func drilTimerServiceDidEnd() {
        super.stop()
        resetTimeLabel()
        waitTimeView?.backgroundColor = .clear
    }
}
