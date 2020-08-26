//
//  GameModel.swift
//  pbdrillapp
//
//  Created by Yaroslav Tytarenko on 11.06.2020.
//  Copyright © 2020 Yaros8T. All rights reserved.
//

import Foundation

struct GameModel {
    let id: Int
    var wait: TimeModel
    var limit: TimeModel

    static var `default`: GameModel = GameModel(id: 1,
                                                wait: TimeModel(id: 1, name: "Pause time:", value: 25, range: 0 ... 120, icon: "iconTime"),
                                                limit: TimeModel(id: 2, name: "Limit time:", value: 0, range: 0 ... 600, icon: "iconDelay"))
}

extension GameModel: Codable {}
