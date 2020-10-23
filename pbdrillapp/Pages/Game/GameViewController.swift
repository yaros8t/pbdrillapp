import UIKit

final class GameViewController: BaseDrillViewController {
    private var model: GameModel!
    private var waitTimeView: TimeView?
    private var limitTimeView: TimeView?

    private lazy var service: GameTimerService = GameTimerService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        model = storage.getGameSettings()

        waitTimeView = addTimeView(with: model.wait)
        limitTimeView = addTimeView(with: model.limit)
        
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

        if time.id == model.wait.id {
            model.wait = time
            waitTimeView?.setup(model: time)
        } else if time.id == model.limit.id {
            model.limit = time
            limitTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        storage.save(settings: model)
    }
    
    private func resetTimeViews() {
        waitTimeView?.setupRegularMode()
        limitTimeView?.setupRegularMode()
        timeView(waitTimeView!, didSelect: false)
        timeView(limitTimeView!, didSelect: false)
    }
    
    private func resetTimeLabel() {
        timeLabel.text = "\(model.wait.value)s"
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
