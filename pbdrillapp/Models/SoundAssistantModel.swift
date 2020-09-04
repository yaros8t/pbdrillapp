import Foundation


struct SoundAssistantModel {
    let id: Int
    var drill: TimeModel
    var repeats: TimeModel
    var firstTags: [String]
    var secondTags: [String]

    static var `default`: SoundAssistantModel = SoundAssistantModel(id: 1,
                                                                    drill: TimeModel(id: 1, name: "Drill time:", value: 3, range: 0 ... 60, icon: "iconTime"),
                                                                    repeats: TimeModel(id: 3, name: "Repeats:", value: 2, range: 1 ... 200, icon: "iconReplay"),
                                                                    firstTags: ["10", "30", "50"],
                                                                    secondTags: ["1", "2", "3", "5"])
}

extension SoundAssistantModel: Codable {}
