import UIKit


final class RunButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.2196078431, blue: 0.3215686275, alpha: 1)
                tintColor = #colorLiteral(red: 0.9647058824, green: 0.2196078431, blue: 0.3215686275, alpha: 1)
            } else {
                backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
                tintColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
            }
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
        setTitle("start", for: .normal)
        setTitleColor(#colorLiteral(red: 0.1137254902, green: 0.1176470588, blue: 0.1176470588, alpha: 1), for: .normal)
        
        setTitle("stop", for: .selected)
        setTitleColor(#colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1), for: .selected)

        isSelected = false
    }
}
