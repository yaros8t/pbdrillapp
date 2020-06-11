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
    let options: [TimeModel]

    static var `default`: DrillModel = DrillModel(id: 1,
                                                  options: [
                                                      TimeModel(name: "Pause time:", value: 12, range: 0...100, icon: "iconTime"),
                                                      TimeModel(name: "Drill time:", value: 14, range: 0...100, icon: "iconDelay"),
                                                      TimeModel(name: "Repeats:", value: 16, range: 0...100, icon: "iconReplay"),
                                                  ])
}

extension DrillModel: Codable {}
