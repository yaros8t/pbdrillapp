import Foundation

struct TimeModel {
    let id: Int
    let name: String
    var value: Int
    let range: ClosedRange<Int>
    let icon: String
    let format: String
}

extension TimeModel: Hashable {}

extension TimeModel: Codable {}

extension TimeModel {
    static var drillPauseTime = TimeModel(id: 1, name: "Pause time:", value: 3, range: 0 ... 60, icon: "iconTime", format: "s")
    static var drillTime = TimeModel(id: 2, name: "Drill time:", value: 4, range: 0 ... 100, icon: "iconDelay", format: "s")
    static var drillRepeats = TimeModel(id: 3, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay", format: "times")
    static var gameWait = TimeModel(id: 4, name: "Wait time:", value: 25, range: 0 ... 120, icon: "iconTime", format: "s")
    static var gameLimit = TimeModel(id: 5, name: "Limit time:", value: 0, range: 0 ... 600, icon: "iconDelay", format: "s")
    static var saDrillTime = TimeModel(id: 6, name: "Drill time:", value: 3, range: 0 ... 60, icon: "iconTime", format: "s")
    static var saRepeatsTime = TimeModel(id: 7, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay", format: "times")
}
