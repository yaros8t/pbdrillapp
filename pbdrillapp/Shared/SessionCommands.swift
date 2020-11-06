import UIKit
import WatchConnectivity


protocol SessionCommands {
    func updateDrillTimerState(_ message: [String: Any])
    func updateGameTimerState(_ message: [String: Any])
    func updateSoundTimerState(_ message: [String: Any])
}

extension SessionCommands {
    
    func updateAppContext(_ context: [String: Any]) {
        var commandStatus = CommandStatus(command: .updateAppContext, phrase: .updated)
        commandStatus.model = context
        
        guard WCSession.default.activationState == .activated else {
            return handleSessionUnactivated(with: commandStatus)
        }
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            commandStatus.phrase = .failed
            commandStatus.errorMessage = error.localizedDescription
        }
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }
    
    func updateDrillTimerState(_ message: [String: Any]) {
        handleMessage(message, CommandStatus(command: .updateDrillTimerState, phrase: .sent))
    }

    func updateGameTimerState(_ message: [String: Any]) {
        handleMessage(message, CommandStatus(command: .updateGameTimerState, phrase: .sent))
    }
    
    func updateSoundTimerState(_ message: [String: Any]) {
        handleMessage(message, CommandStatus(command: .updateSoundTimerState, phrase: .sent))
    }
    
    private func handleMessage(_ message: [String: Any], _ commandStatus: CommandStatus) {
        guard WCSession.default.activationState == .activated else { return handleSessionUnactivated(with: commandStatus) }
        var commandStatus = commandStatus
        
        WCSession.default.sendMessage(message, replyHandler: { replyMessage in
            commandStatus.phrase = .replied
            commandStatus.model = replyMessage
            self.postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)

        }, errorHandler: { error in
            commandStatus.phrase = .failed
            commandStatus.errorMessage = error.localizedDescription
            self.postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
        })
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }

    private func postNotificationOnMainQueueAsync(name: NSNotification.Name, object: CommandStatus) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object)
        }
    }

    private func handleSessionUnactivated(with commandStatus: CommandStatus) {
        var mutableStatus = commandStatus
        mutableStatus.phrase = .failed
        mutableStatus.errorMessage =  "WCSession is not activeted yet!"
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }
}
