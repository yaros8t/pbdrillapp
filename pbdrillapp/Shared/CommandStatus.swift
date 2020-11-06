import UIKit
import WatchConnectivity

enum Command: String {
    case updateAppContext = "UpdateAppContext"
    case updateDrillTimerState = "UpdateDrillTimerState"
    case updateGameTimerState = "UpdateGameTimerState"
    case updateSoundTimerState = "UpdateSoundTimerState"
}

enum Phrase: String {
    case updated = "Updated"
    case sent = "Sent"
    case received = "Received"
    case replied = "Replied"
    case transferring = "Transferring"
    case canceled = "Canceled"
    case finished = "Finished"
    case failed = "Failed"
}

struct CommandStatus {
    var command: Command
    var phrase: Phrase
    var model: [String: Any]?
    var timerIsRunned: Bool = false
    var errorMessage: String?
    
    init(command: Command, phrase: Phrase) {
        self.command = command
        self.phrase = phrase
    }
}
