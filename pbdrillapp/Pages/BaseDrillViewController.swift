//
//  BaseDrillViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 11.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

protocol BaseDrillViewControllerDelegate: class {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel)
    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode model: TimeModel)
    
    func drillViewController(_ controller: BaseDrillViewController, didStartTimer model: DrillModel)
    func drillViewController(_ controller: BaseDrillViewController, didStopTimer model: DrillModel)
}

class BaseDrillViewController: UIViewController {

    weak var delegate: BaseDrillViewControllerDelegate?
    var mode: Mode = .regular
    var isRunned: Bool = false
    
    enum Mode {
        case regular
        case edit
    }
    
    func changeMode(_ mode: Mode) {
    }
    
    func applyNewValue() {}
    
    func cancelNewValue() {}
}
