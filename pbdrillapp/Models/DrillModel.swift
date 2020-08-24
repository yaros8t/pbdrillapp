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
    let pause: TimeModel
    let total: TimeModel
    let repeats: TimeModel
    
    static var `default`: DrillModel = DrillModel(id: 1,
                                                  pause: TimeModel(name: "Pause time:", value: 12, range: 0...30, icon: "iconTime"),
                                                  total: TimeModel(name: "Drill time:", value: 14, range: 0...100, icon: "iconDelay"),
                                                  repeats: TimeModel(name: "Repeats:", value: 16, range: 0...10, icon: "iconReplay")
                                                  )
}

extension DrillModel: Codable {}
