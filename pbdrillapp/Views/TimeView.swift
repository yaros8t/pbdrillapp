//
//  TimeView.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

protocol TimeViewDelegate: class {
    func timeView(_ view: TimeView, didSelect: Bool)
}

class TimeView: UIView {
    weak var delegate: TimeViewDelegate?
    var model: TimeModel?

    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let button = TimeButton(frame: .zero)

    private var timeLabelXCnstr: NSLayoutConstraint!
    private var timeLabelLCnstr: NSLayoutConstraint!

    private var titleLabelVCnstr: NSLayoutConstraint!
    private var timeLabelVCnstr: NSLayoutConstraint!

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
        timeLabel.text = "\(model.value)"

        let image = UIImage(named: model.icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .selected)
        button.tintColor = .black
    }

    func update(value: String) {
        timeLabel.text = value
    }

    private func commonSetup() {
        timeLabel.font = UIFont.systemFont(ofSize: 30)
        timeLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.262745098, blue: 0.2705882353, alpha: 1)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        timeLabelVCnstr = timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        timeLabelLCnstr = leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor)
        timeLabelXCnstr = timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        NSLayoutConstraint.activate([timeLabelLCnstr, timeLabelVCnstr])

        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.262745098, blue: 0.2705882353, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabelVCnstr = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        let titleLabelLCnstr = leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        NSLayoutConstraint.activate([titleLabelVCnstr, titleLabelLCnstr])

        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        let buttonVCnstr = button.centerYAnchor.constraint(equalTo: centerYAnchor)
        let buttonTCnstr = trailingAnchor.constraint(equalTo: button.trailingAnchor)
        let buttonWCnstr = button.widthAnchor.constraint(equalToConstant: 53)
        let buttonHCnstr = button.heightAnchor.constraint(equalToConstant: 53)
        NSLayoutConstraint.activate([buttonVCnstr, buttonTCnstr, buttonWCnstr, buttonHCnstr])

//        backgroundColor = .green

        layer.cornerRadius = 8.0
        layer.masksToBounds = true

        setupRegularMode(animated: false)
    }

    @objc private func tap() {
        delegate?.timeView(self, didSelect: true)
    }

    func setActive(_ active: Bool) {
        var color: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if active {
            color = #colorLiteral(red: 0.2549019608, green: 0.262745098, blue: 0.2705882353, alpha: 1)
        } else {
            color = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)
        }

        titleLabel.textColor = color
        timeLabel.textColor = color
    }

    func setButtonActive(_ active: Bool) {
        if active {
            button.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.262745098, blue: 0.2705882353, alpha: 1)
            button.tintColor = .white
        } else {
            button.backgroundColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8705882353, alpha: 1)
            button.tintColor = .black
        }
    }

    func setupEditMode(animated: Bool = true) {
        button.isSelected = true

        timeLabelXCnstr.isActive = false
        timeLabelLCnstr.isActive = true
        titleLabelVCnstr.constant = -14
        timeLabelVCnstr.constant = 10

        let duration: TimeInterval = animated ? 0.3 : 0
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: duration) {
            self.timeLabel.transform = .identity
        }
    }

    func setupRegularMode(animated: Bool = true) {
        button.isSelected = false

        timeLabelLCnstr.isActive = false
        timeLabelXCnstr.isActive = true
        titleLabelVCnstr.constant = 0
        timeLabelVCnstr.constant = 0

        let duration: TimeInterval = animated ? 0.3 : 0
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }

        UIView.animate(withDuration: duration) {
            self.timeLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        setActive(true)
        setButtonActive(false)
    }
}
