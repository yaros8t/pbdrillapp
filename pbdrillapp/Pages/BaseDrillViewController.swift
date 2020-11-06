import UIKit
import WatchConnectivity

protocol BaseDrillViewControllerDelegate: class {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel)
    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode model: TimeModel)

    func drillViewControllerDidStartTimer()
    func drillViewControllerDidStopTimer()
}

class BaseDrillViewController: UIViewController, SessionCommands {
    
    @IBOutlet var reachableLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var runButton: RunButton!
    @IBOutlet var runButtonCenterY: NSLayoutConstraint!
    
    @IBOutlet var constraints: [NSLayoutConstraint]!
    
    weak var delegate: BaseDrillViewControllerDelegate?

    var isRunned: Bool = false

    lazy var storage: Storage = Storage()

    var selectedTimeViews: [TimeView: Bool] = [:]
    var selectedTime: TimeModel?

    enum Mode {
        case regular
        case edit
    }
    
    private lazy var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.tapToBackground))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).activationDidComplete(_:)),
            name: .activationDidComplete, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).reachabilityDidChange(_:)),
            name: .reachabilityDidChange, object: nil
        )
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // iPhone 5 or 5S or 5C
                    stackView?.spacing = 4.0
                    constraints?.forEach { constraint in
                        constraint.constant = constraint.constant / 2
                    }
            default:
                break
            }
        }
        
        view.addGestureRecognizer(tap)
        
        stackView?.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    @IBAction func didSekectRunButton(_ sender: RunButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            start()
        } else {
            stop()
        }
    }
    
    @objc func tapToBackground() {
        selectedTimeViews.forEach { (key: TimeView, value: Bool) in
            timeView(key, didSelect: false)
        }
    }
    
    func save(_ time: TimeModel?) {}

    func addTimeView(with model: TimeModel?) -> TimeView {
        guard let model = model else { fatalError() }
        
        let timeView = TimeView()
        timeView.delegate = self
        timeView.translatesAutoresizingMaskIntoConstraints = false
        timeView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        timeView.setup(model: model)
        timeView.setupRegularMode(animated: false)
        stackView.addArrangedSubview(timeView)

        return timeView
    }

    func startEditMode(_ view: TimeView) {
        view.setupEditMode()
    }

    func endEditMode(_ view: TimeView) {
        view.setupRegularMode()
        runButton.isSelected = false
    }

    func start() {
        
        isRunned = true
        runButton.isSelected = true
        delegate?.drillViewControllerDidStartTimer()
    }

    func stop() {
        isRunned = false
        runButton.isSelected = false
        delegate?.drillViewControllerDidStopTimer()
    }
    
    // MARK: - Time Label
    func setTimeValue(_ value: Int) {
        timeLabel.text = Formater.secondsToHoursMinutesSeconds(interval: value)
    }
    
    // .activationDidComplete notification handler.
    //
    @objc
    func activationDidComplete(_ notification: Notification) {
        updateReachabilityColor()
    }
    
    // .reachabilityDidChange notification handler.
    //
    @objc
    func reachabilityDidChange(_ notification: Notification) {
        updateReachabilityColor()
    }
    
    // .dataDidFlow notification handler.
    // Update the UI based on the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
    }
}

extension BaseDrillViewController: TimeViewDelegate {
    
    func timeView(_ view: TimeView, didSelect: Bool) {
        guard !isRunned else { UINotificationFeedbackGenerator().notificationOccurred(.error); return }
        
        if selectedTimeViews[view] == true || !didSelect {
            selectedTimeViews[view] = false
            view.setupRegularMode()
            
            save(view.model)
            
        } else {
            selectedTimeViews[view] = true
            view.setupEditMode()
        }
    }
    
    func timeView(_ view: TimeView, change value: Int) {}
}

extension BaseDrillViewController {
    
    func updateReachabilityColor() {
        // WCSession.isReachable triggers a warning if the session is not activated.
        var isReachable = false
        if WCSession.default.activationState == .activated {
            isReachable = WCSession.default.isReachable
        }
        reachableLabel.backgroundColor = isReachable ? .green : .red
    }
}
