import UIKit


final class RunButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(named: "stop")
                tintColor = UIColor(named: "stop")
            } else {
                backgroundColor = UIColor(named: "start")
                tintColor = UIColor(named: "start")
            }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
    }

    private func commonSetup() {
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.adjustsFontSizeToFitWidth = true
        
        setTitle("start".localized, for: .normal)
        setTitleColor(#colorLiteral(red: 0.1137254902, green: 0.1176470588, blue: 0.1176470588, alpha: 1), for: .normal)
        
        setTitle("stop".localized, for: .selected)
        setTitleColor(#colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1), for: .selected)

        isSelected = false
    }
}
