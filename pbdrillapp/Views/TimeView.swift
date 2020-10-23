import UIKit
import TactileSlider

protocol TimeViewDelegate: class {
    func timeView(_ view: TimeView, didSelect: Bool)
}

final class TimeView: UIView {
    weak var delegate: TimeViewDelegate?
    var model: TimeModel?

    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let button = TimeButton(frame: .zero)

    private var timeLabelXCnstr: NSLayoutConstraint!
    private var timeLabelLCnstr: NSLayoutConstraint!

    private var titleLabelVCnstr: NSLayoutConstraint!
    private var timeLabelVCnstr: NSLayoutConstraint!
    
    private var slider: TactileSlider?

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    func setup(model: TimeModel) {
        self.model = model

        titleLabel.text = model.name
        update(value: "\(model.value)")

        let image = UIImage(named: model.icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .selected)
        button.tintColor = UIColor(named: "timeButtonIcon")
    }

    func update(value: String) {
        timeLabel.text = value + " " + model!.format
    }

    private func commonSetup() {
        timeLabel.font = UIFont.systemFont(ofSize: 30)
        timeLabel.textColor = UIColor(named: "timeText")
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        timeLabelVCnstr = timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 00)
        timeLabelLCnstr = leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor)
        timeLabelXCnstr = timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        NSLayoutConstraint.activate([timeLabelLCnstr, timeLabelVCnstr])

        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor(named: "titleText")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabelVCnstr = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
        let titleLabelLCnstr = leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        NSLayoutConstraint.activate([titleLabelVCnstr, titleLabelLCnstr])

        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        let buttonVCnstr = button.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
        let buttonTCnstr = trailingAnchor.constraint(equalTo: button.trailingAnchor)
        let buttonWCnstr = button.widthAnchor.constraint(equalToConstant: 52)
        let buttonHCnstr = button.heightAnchor.constraint(equalToConstant: 52)
        NSLayoutConstraint.activate([buttonVCnstr, buttonTCnstr, buttonWCnstr, buttonHCnstr])

        layer.cornerRadius = 8.0
        layer.masksToBounds = true

        setupRegularMode(animated: false)
    }

    @objc private func tap() {
        delegate?.timeView(self, didSelect: true)
    }
    
    @objc private func valueChanged() {
        updateModelValue()
        update(value: "\(Int(slider!.value))")
    }

    func setupEditMode(animated: Bool = true) {
        button.isSelected = true
        
        slider?.removeFromSuperview()
        slider = TactileSlider(frame: CGRect(origin: .zero, size: frame.size))
        slider?.trackBackground = UIColor(named: "sliderTrackBackground")!
        slider?.tintColor = UIColor(named: "sliderTrack")!
        slider?.cornerRadius = 15
        slider?.isPointerInteractionEnabled = true
        slider?.feedbackStyle = .medium
        slider?.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        slider?.minimum = Float(model!.range.min() ?? 0)
        slider?.maximum = Float(model!.range.max() ?? 0)
        slider?.setValue(Float(model?.value ?? 0), animated: false)
        addSubview(slider!)
        sendSubviewToBack(slider!)
        
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.alpha = 0
        }
        
        button.backgroundColor = .clear
        button.tintColor = .white
    }

    func setupRegularMode(animated: Bool = true) {
        button.isSelected = false
        
        slider?.removeFromSuperview()

        timeLabelLCnstr.isActive = false
        timeLabelXCnstr.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.alpha = 1
        }
        
        button.backgroundColor = UIColor(named: "timeButton")
        button.tintColor = UIColor(named: "timeButtonIcon")
        
        updateModelValue()
    }
    
    private func updateModelValue() {
        guard let slider = slider else { return }
        
        var newModel = model
        newModel?.value = Int(slider.value)
        model = newModel
    }
}

