import Foundation
import WatchConnectivity

#if os(watchOS)
import ClockKit
#endif

extension Notification.Name {
    static let dataDidFlow = Notification.Name("DataDidFlow")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

final class SessionDelegater: NSObject, WCSessionDelegate {
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        var commandStatus = CommandStatus(command: .updateAppContext, phrase: .received)
        commandStatus.model = applicationContext
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        postNotificationOnMainQueueAsync(name: .activationDidComplete)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        postNotificationOnMainQueueAsync(name: .reachabilityDidChange)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        var commandStatus = CommandStatus(command: .updateDrillTimerState, phrase: .received)
        commandStatus.model = message
        postNotificationOnMainQueueAsync(name: .dataDidFlow, object: commandStatus)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        self.session(session, didReceiveMessage: message)
        replyHandler(message)
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif

    private func postNotificationOnMainQueueAsync(name: NSNotification.Name, object: CommandStatus? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: object)
        }
    }
}

