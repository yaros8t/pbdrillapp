import UIKit
import TactileSlider

final class DrillViewController: BaseDrillViewController {
    
    private var model: DrillModel!
    
    private var drillTimeView: TimeView?
    private var pauseTimeView: TimeView?
    private var repeatsTimeView: TimeView?
    private lazy var service: DrilTimerService = DrilTimerService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        model = storage.getDrillModel(type: .training)
        drillTimeView = addTimeView(with: model.drillTime)
        pauseTimeView = addTimeView(with: model.drillPauseTime)
        repeatsTimeView = addTimeView(with: model.drillRepeats)
        
        updateDrillTimerState(model.dictionary)
        
        resetTimeLabel()
    }

    override func start() {
        guard !isRunned else { return }
        resetTimeViews()
        super.start()
        service.start(with: model)
    }

    override func stop() {
        guard isRunned else { return }
        super.stop()
        service.stop()

        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        
        resetTimeLabel()
    }
    
    private func resetTimeLabel() {
        if model.drillPauseTime.value != 0 {
            timeLabel.text = "\(model.drillPauseTime.value)s"
        } else {
            timeLabel.text = "\(model.drillTime.value)s"
        }
    }
    
    private func resetTimeViews() {
        drillTimeView?.setupRegularMode()
        pauseTimeView?.setupRegularMode()
        repeatsTimeView?.setupRegularMode()
        timeView(drillTimeView!, didSelect: false)
        timeView(pauseTimeView!, didSelect: false)
        timeView(repeatsTimeView!, didSelect: false)
    }

    override func save(_ time: TimeModel?) {
        guard let time = time else { assert(false); return }

        if time.type == .drillPauseTime {
            pauseTimeView?.setup(model: time)
        } else if time.type == .drillTime {
            drillTimeView?.setup(model: time)
        } else if time.type == .drillRepeats {
            repeatsTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        model.update(time)
        storage.save(settings: model)
    }
    
    @objc
    override func dataDidFlow(_ notification: Notification) {
        guard let commandStatus = notification.object as? CommandStatus else { return }
        guard commandStatus.command == .updateDrillTimerState else { return }
        
//        start()
    }
}

extension DrillViewController: DrilTimerServiceDelegate {
    func drilTimerService(_: DrilTimerService, didUpdateDrill time: Int) {
        setTimeValue(time)
        pauseTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = UIColor(named: "timeHighlight")
        }
    }

    func drilTimerService(_: DrilTimerService, didUpdatePause time: Int) {
        setTimeValue(time)
        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.pauseTimeView?.backgroundColor = UIColor(named: "timeHighlight")
        }
    }

    func drilTimerService(_: DrilTimerService, didUpdateRepeats count: Int) {
        drillTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        UIView.animate(withDuration: 0.3) {
            self.repeatsTimeView?.backgroundColor = UIColor(named: "timeHighlight")
        }

        repeatsTimeView?.update(value: "\(count)")
    }

    func drilTimerServiceDidEnd() {
        stop()
    }
}
