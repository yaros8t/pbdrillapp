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
                                                wait: TimeModel.gameWait,
                                                limit: TimeModel.gameLimit)
}

extension GameModel: Codable {}
