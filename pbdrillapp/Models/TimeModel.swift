import Foundation

enum TimeModelType: Int {
    case none
    case drillPauseTime
    case drillTime
    case drillRepeats
    case gameWait
    case gameLimit
    case saDrillTime
    case saRepeatsTime
}

extension TimeModelType: Codable {}

extension TimeModelType: Emptyable {
    static var emptyValue: TimeModelType { .none }
}

struct TimeModel {
    let type: TimeModelType
    let name: String
    var value: Int
    let range: ClosedRange<Int>
    let icon: String
    let format: String

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case value
        case range
        case icon
        case format
    }
}

extension TimeModel: Hashable {}

extension TimeModel: Codable {}

extension TimeModel {
    static var drillPauseTime = TimeModel(type: .drillPauseTime, name: "Pause time:", value: 3, range: 0 ... 60, icon: "iconTime", format: "s")
    static var drillTime = TimeModel(type: .drillTime, name: "Drill time:", value: 4, range: 0 ... 100, icon: "iconDelay", format: "s")
    static var drillRepeats = TimeModel(type: .drillRepeats, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay", format: "times")
    static var gameWait = TimeModel(type: .gameWait, name: "Wait time:", value: 25, range: 0 ... 120, icon: "iconTime", format: "s")
    static var gameLimit = TimeModel(type: .gameLimit, name: "Limit time:", value: 0, range: 0 ... 600, icon: "iconDelay", format: "s")
    static var saDrillTime = TimeModel(type: .saDrillTime, name: "Drill time:", value: 3, range: 0 ... 60, icon: "iconTime", format: "s")
    static var saRepeatsTime = TimeModel(type: .saRepeatsTime, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay", format: "times")
}
