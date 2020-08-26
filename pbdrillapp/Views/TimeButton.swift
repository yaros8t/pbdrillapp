//
//  TimeButton.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

class TimeButton: UIButton {
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
