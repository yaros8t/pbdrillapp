//
//  SoundAssistantModel.swift
//  pbdrillapp
//
//  Created by Yaroslav Tytarenko on 26.08.2020.
//  Copyright © 2020 Yaros8T. All rights reserved.
//

import Foundation


struct SoundAssistantModel {
    let id: Int
    var drill: TimeModel
    var repeats: TimeModel

    static var `default`: SoundAssistantModel = SoundAssistantModel(id: 1,
                                                  drill: TimeModel(id: 1, name: "Drill time:", value: 3, range: 0 ... 60, icon: "iconTime"),
                                                  repeats: TimeModel(id: 3, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay"))
}

extension SoundAssistantModel: Codable {}
