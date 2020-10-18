import Foundation


struct SoundAssistantModel {
    let id: Int
    var drill: TimeModel
    var repeats: TimeModel
    var firstTags: [String]
    var secondTags: [String]

    static var `default`: SoundAssistantModel = SoundAssistantModel(id: 1,
                                                                    drill: .saDrillTime,
                                                                    repeats: .saRepeatsTime,
                                                                    firstTags: ["10", "30", "50"],
                                                                    secondTags: ["1", "2", "3", "5"])
}

extension SoundAssistantModel: Codable {}
