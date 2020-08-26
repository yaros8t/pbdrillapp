//
//  DrillModel.swift
//  pbdrillapp
//
//  Created by Yaroslav Tytarenko on 11.06.2020.
//  Copyright © 2020 Yaros8T. All rights reserved.
//

import Foundation

struct DrillModel {
    let id: Int
    var pause: TimeModel
    var total: TimeModel
    var repeats: TimeModel

    static var `default`: DrillModel = DrillModel(id: 1,
                                                  pause: TimeModel(id: 1, name: "Pause time:", value: 3, range: 0 ... 60, icon: "iconTime"),
                                                  total: TimeModel(id: 2, name: "Drill time:", value: 4, range: 0 ... 100, icon: "iconDelay"),
                                                  repeats: TimeModel(id: 3, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay"))
}

extension DrillModel: Codable {}
