//
//  Storage.swift
//  PaintballTrainingWatch WatchKit Extension
//
//  Created by Yaroslav Tytarenko on 22.03.2020.
//  Copyright © 2020 Yaroslav Tytarenko. All rights reserved.
//

import Foundation

private let kDrillModel = "DrillModel"
private let kGameModel = "GameModel"

final class Storage {
    private lazy var defaults: UserDefaults = UserDefaults.standard

    func save(settings: DrillModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kDrillModel)
    }

    func save(settings: GameModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kGameModel)
    }

    func getDrillModel() -> DrillModel {
        if let data = UserDefaults.standard.object(forKey: kDrillModel) as? Data {
            if let settings = try? JSONDecoder().decode(DrillModel.self, from: data) {
                return settings
            } else {
                return DrillModel.default
            }
        } else {
            return DrillModel.default
        }
    }

    func getGameSettings() -> GameModel {
        if let data = UserDefaults.standard.object(forKey: kGameModel) as? Data {
            if let settings = try? JSONDecoder().decode(GameModel.self, from: data) {
                return settings
            } else {
                return GameModel.default
            }
        } else {
            return GameModel.default
        }
    }
}
