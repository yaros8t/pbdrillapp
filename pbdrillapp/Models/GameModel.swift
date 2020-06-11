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
    let limit: Int
    let wait: Int
    
    static var `default`: GameModel = GameModel(id: 1, limit: 0, wait: 45)
}

extension GameModel: Codable { }
