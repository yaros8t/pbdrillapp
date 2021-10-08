import Foundation

struct TimeModel {
    
    let id: Int
    let name: String
    var value: Int
    let range: ClosedRange<Int>
    let icon: String
    let format: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case value
    }
    
    internal init(id: Int, name: String, value: Int, range: ClosedRange<Int>, icon: String, format: String) {
        self.id = id
        self.name = name
        self.value = value
        self.range = range
        self.icon = icon
        self.format = format
    }
    
    init(id: Int, value: Int) {
        self.id = id
        self.value = value
        
        switch TimeModelSettings(rawValue: id) {
        case .drillPauseTime:
            name = "pause_time".localized
            range = 0 ... 60
            icon = "iconTime"
            format = "s".localized
        case .drillTime:
            self.name = "drill_time".localized
            self.range = 0 ... 100
            self.icon = "iconDelay"
            self.format = "s".localized
        case .drillRepeats:
            self.name = "repeats".localized
            self.range = 1 ... 200
            self.icon = "iconReplay"
            self.format = ""
        case .gameWait:
            self.name = "wait_time".localized
            self.range = 0 ... 120
            self.icon = "iconTime"
            self.format = "s".localized
        case .gameLimit:
            self.name = "limit_time".localized
            self.range = 0 ... 600
            self.icon = "iconDelay"
            self.format = "s".localized
        case .saDrillTime:
            self.name = "drill_time".localized
            self.range = 0 ... 60
            self.icon = "iconTime"
            self.format = "s".localized
        case .saRepeatsTime:
            self.name = "repeats".localized
            self.range = 1 ... 200
            self.icon = "iconReplay"
            self.format = ""
        case .none:
            self.name = ""
            self.range = 0 ... 1
            self.icon = ""
            self.format = ""
        }
    }
}

extension TimeModel: Hashable {}

extension TimeModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let _id = try values.decode(Int.self, forKey: .id)
        let _value = try values.decode(Int.self, forKey: .value)
        self.init(id: _id, value: _value)
    }
}

extension TimeModel: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
    }
}

extension TimeModel {
    static var drillPauseTime = TimeModel(id: 1, value: 3)
    static var drillTime = TimeModel(id: 2, value: 4)
    static var drillRepeats = TimeModel(id: 3, value: 2)
    static var gameWait = TimeModel(id: 4, value: 25)
    static var gameLimit = TimeModel(id: 5, value: 0)
    static var saDrillTime = TimeModel(id: 6, value: 3)
    static var saRepeatsTime = TimeModel(id: 7, value: 2)
}

enum TimeModelSettings: Int {
    case drillPauseTime = 1
    case drillTime = 2
    case drillRepeats = 3
    case gameWait = 4
    case gameLimit = 5
    case saDrillTime = 6
    case saRepeatsTime = 7
}
