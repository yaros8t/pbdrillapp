import WatchKit
import WatchConnectivity

final class ExtensionDelegate: NSObject, WKExtensionDelegate {

    private lazy var sessionDelegater: SessionDelegater = SessionDelegater()

    private var activationStateObservation: NSKeyValueObservation?
    private var hasContentPendingObservation: NSKeyValueObservation?

    private var wcBackgroundTasks = [WKWatchConnectivityRefreshBackgroundTask]()
    
    override init() {
        super.init()
        assert(WCSession.isSupported(), "This sample requires a platform supporting Watch Connectivity!")

        activationStateObservation = WCSession.default.observe(\.activationState) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }
        hasContentPendingObservation = WCSession.default.observe(\.hasContentPending) { _, _ in
            DispatchQueue.main.async {
                self.completeBackgroundTasks()
            }
        }

        WCSession.default.delegate = sessionDelegater
        WCSession.default.activate()
    }

    func completeBackgroundTasks() {
        guard !wcBackgroundTasks.isEmpty else { return }

        guard WCSession.default.activationState == .activated,
            WCSession.default.hasContentPending == false else { return }
        
        wcBackgroundTasks.forEach { $0.setTaskCompletedWithSnapshot(true) }
        
        Logger.shared.append(line: "\(#function):\(wcBackgroundTasks) was completed!")

        let date = Date(timeIntervalSinceNow: 1)
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: date, userInfo: nil) { error in
            if let error = error {
                print("scheduleSnapshotRefresh error: \(error)!")
            }
        }
        wcBackgroundTasks.removeAll()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if let wcTask = task as? WKWatchConnectivityRefreshBackgroundTask {
                wcBackgroundTasks.append(wcTask)
                Logger.shared.append(line: "\(#function):\(wcTask.description) was appended!")
            } else {
                task.setTaskCompletedWithSnapshot(true)
                Logger.shared.append(line: "\(#function):\(task.description) was completed!")
            }
        }
        completeBackgroundTasks()
    }
}

