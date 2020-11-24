import Foundation

enum DrillModelType: Int {
    case training = 1
    case game = 2
    case rand = 3
    
    var name: String {
        switch self {
        case .training:
            return "Training"
        case .game:
            return "Game"
        case .rand:
            return "Sound Assistant"
        }
    }
    
    var str: String {
        switch self {
        case .training:
            return "training"
        case .game:
            return "game"
        case .rand:
            return "rand"
        }
    }
}

extension DrillModelType: Codable {}

struct DrillModel {
    
    let type: DrillModelType
    var options: [TimeModel]
    var firstTags: [String]
    var secondTags: [String]
    
    private enum CodingKeys: String, CodingKey {
        case type
        case options
        case firstTags
        case secondTags
    }
}

extension DrillModel {
    
    var drillTime: TimeModel { options.filter({ $0.type == .drillTime }).first! }
    var drillRepeats: TimeModel { options.filter({ $0.type == .drillRepeats }).first! }
    var drillPauseTime: TimeModel { options.filter({ $0.type == .drillPauseTime }).first! }
    
    var gameWait: TimeModel { options.filter({ $0.type == .gameWait }).first! }
    var gameLimit: TimeModel { options.filter({ $0.type == .gameLimit }).first! }
    
    var saDrillTime: TimeModel { options.filter({ $0.type == .saDrillTime }).first! }
    var saRepeatsTime: TimeModel { options.filter({ $0.type == .saRepeatsTime }).first! }
}

extension DrillModel {
    
    mutating func update(_ model: TimeModel) {
        if let index = options.firstIndex(where: { $0.name == model.name }) {
            options.remove(at: index)
            options.insert(model, at: index)
        } else {
            assert(false)
        }
    }
}

extension DrillModel {
    
    static var training: DrillModel = DrillModel(type: .training, options: [.drillPauseTime, .drillTime, .drillRepeats], firstTags: [], secondTags: [])
    static var game: DrillModel = DrillModel(type: .game, options: [.gameWait, .gameLimit], firstTags: [], secondTags: [])
    static var rand: DrillModel = DrillModel(type: .rand, options: [.saDrillTime, .saRepeatsTime], firstTags: ["10", "30", "50"], secondTags: ["1", "2", "3", "5"])
    
    static func initDefault(_ type: DrillModelType) -> DrillModel {
        switch type {
        case .training:
            return .training
        case .game:
            return .game
        case .rand:
            return .rand
        }
    }
}

extension DrillModel: Codable { }
