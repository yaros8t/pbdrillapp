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
