//
//  ConfirmView.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 09.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

final class ConfirmView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    var doneAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    private(set) lazy var titlelabel = UILabel()
    private(set) lazy var descLabel = UILabel()

    private func commonSetup() {
        backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        layer.cornerRadius = 38.0
        layer.masksToBounds = true

        titlelabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        titlelabel.textColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
        addSubview(titlelabel)
        NSLayoutConstraint.activate([
            titlelabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titlelabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        addSubview(descLabel)
        NSLayoutConstraint.activate([
            descLabel.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 10),
            descLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            leadingAnchor.constraint(equalTo: descLabel.leadingAnchor, constant: -16),
            trailingAnchor.constraint(equalTo: descLabel.trailingAnchor, constant: 16),
        ])

        let doneButton = UIButton()
        doneButton.layer.cornerRadius = 15.0
        doneButton.layer.masksToBounds = true
        doneButton.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.5529411765, blue: 0.5529411765, alpha: 1)
        doneButton.setImage(#imageLiteral(resourceName: "iconDone"), for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(tapToDoneAction), for: .touchUpInside)
        addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 53),
            doneButton.heightAnchor.constraint(equalToConstant: 53),
        ])

        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 15.0
        cancelButton.layer.masksToBounds = true
        cancelButton.backgroundColor = #colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
        cancelButton.setImage(#imageLiteral(resourceName: "iconClose"), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(tapToCancelAction), for: .touchUpInside)
        addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 53),
            cancelButton.heightAnchor.constraint(equalToConstant: 53),
        ])

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 40
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(doneButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 40),
        ])
    }

    @objc private func tapToDoneAction() {
        doneAction?()
    }

    @objc private func tapToCancelAction() {
        cancelAction?()
    }
}
