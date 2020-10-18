import Foundation

struct DrillModel {
    let id: Int
    var pause: TimeModel
    var total: TimeModel
    var repeats: TimeModel

    static var `default`: DrillModel = DrillModel(id: 1,
                                                  pause: .drillPauseTime,
                                                  total: .drillTime,
                                                  repeats: .drillRepeats)
}

extension DrillModel: Codable {}
