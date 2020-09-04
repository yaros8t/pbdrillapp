import Foundation

private let kDrillModel = "DrillModel"
private let kGameModel = "GameModel"
private let kSoundAssistantModel = "SoundAssistantModel"

final class Storage {
    private lazy var defaults: UserDefaults = UserDefaults.standard

    func save(settings: DrillModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kDrillModel)
    }

    func save(settings: GameModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kGameModel)
    }
    
    func save(settings: SoundAssistantModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kSoundAssistantModel)
    }
    
    func getSoundAssistantModel() -> SoundAssistantModel {
        if let data = UserDefaults.standard.object(forKey: kSoundAssistantModel) as? Data {
            if let settings = try? JSONDecoder().decode(SoundAssistantModel.self, from: data) {
                return settings
            } else {
                return .default
            }
        } else {
            return .default
        }
    }

    func getDrillModel() -> DrillModel {
        if let data = UserDefaults.standard.object(forKey: kDrillModel) as? Data {
            if let settings = try? JSONDecoder().decode(DrillModel.self, from: data) {
                return settings
            } else {
                return .default
            }
        } else {
            return .default
        }
    }

    func getGameSettings() -> GameModel {
        if let data = UserDefaults.standard.object(forKey: kGameModel) as? Data {
            if let settings = try? JSONDecoder().decode(GameModel.self, from: data) {
                return settings
            } else {
                return .default
            }
        } else {
            return .default
        }
    }
}
