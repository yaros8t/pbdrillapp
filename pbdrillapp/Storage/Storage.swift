import Foundation

private let kDrillModel = "DrillModel"

final class Storage {
    private lazy var defaults: UserDefaults = UserDefaults.standard

    func save(settings: DrillModel) {
        defaults.set(try? JSONEncoder().encode(settings), forKey: kDrillModel + "\(settings.type.rawValue)")
    }

    func getDrillModel(type: DrillModelType) -> DrillModel {
        if let data = UserDefaults.standard.object(forKey: kDrillModel + "\(type.rawValue)") as? Data {
            if let settings = try? JSONDecoder().decode(DrillModel.self, from: data) {
                return settings
            } else {
                return DrillModel.initDefault(type)
            }
        } else {
            return DrillModel.initDefault(type)
        }
    }
}
