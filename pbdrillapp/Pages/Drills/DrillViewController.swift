import UIKit
import TactileSlider

final class DrillViewController: BaseDrillViewController {
    
    var drillModel: DrillModel!
    
    @IBOutlet private var timeTitleLabel: UILabel!
    
    private var drillTimeView: TimeView?
    private var pauseTimeView: TimeView?
    private var repeatsTimeView: TimeView?
    private lazy var service: DrilTimerService = DrilTimerService(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "training_timer".localized
        timeTitleLabel.text = ""
        
        drillModel = storage.getDrillModel()

        drillTimeView = addTimeView(with: drillModel.total)
        pauseTimeView = addTimeView(with: drillModel.pause)
        repeatsTimeView = addTimeView(with: drillModel.repeats)
        
        resetTimeLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppStoreReviewManager.requestReviewIfAppropriate()
    }

    override func start() {
        resetTimeViews()
        super.start()
        service.start(with: drillModel)
    }

    override func stop() {
        super.stop()
        service.stop()

        drillTimeView?.backgroundColor = .clear
        repeatsTimeView?.backgroundColor = .clear
        pauseTimeView?.backgroundColor = .clear
        
        resetTimeLabel()
    }
    
    private func resetTimeLabel() {
        if drillModel.pause.value != 0 {
            timeLabel.text = "\(drillModel.pause.value) " + "s".localized
        } else {
            timeLabel.text = "\(drillModel.total.value) " + "s".localized
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

        if time.id == drillModel.pause.id {
            drillModel.pause = time
            pauseTimeView?.setup(model: time)
        } else if time.id == drillModel.total.id {
            drillModel.total = time
            drillTimeView?.setup(model: time)
        } else if time.id == drillModel.repeats.id {
            drillModel.repeats = time
            repeatsTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        storage.save(settings: drillModel)
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
