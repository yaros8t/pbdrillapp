import UIKit

final class TimeButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    private func commonSetup() {
        layer.cornerRadius = 15.0
        layer.masksToBounds = true
    }
}
