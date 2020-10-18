import UIKit


protocol BaseDrillViewControllerDelegate: class {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel)
    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode model: TimeModel)

    func drillViewControllerDidStartTimer()
    func drillViewControllerDidStopTimer()
}

class BaseDrillViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func save(_ time: TimeModel?) {}

    func addTimeView(with model: TimeModel) -> TimeView {
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
        if value <= 0 {
            ()
        }
        
        timeLabel.text = secondsToHoursMinutesSeconds(interval: value)
    }

    // MARK: - Utils
    private func secondsToHoursMinutesSeconds(interval: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(interval))!
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
