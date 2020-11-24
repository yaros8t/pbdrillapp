import Foundation
import WatchKit
import WatchConnectivity

final class RootInterfaceController: WKInterfaceController {
    
    @IBOutlet private var titleLabel: WKInterfaceLabel!
    
    private static var instances = [TrainingInterfaceController]()
    private var context: CommandStatus?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
//        if let context = WCSession.default.receivedApplicationContext as? [String: Any] {
////            self.context = context
////            updateUI(with: context)
////            type(of: self).instances.append(self)
//            reloadRootController(with: context)
//        } else {
            titleLabel.setText("Activating...")
//            reloadRootController(with: [])
//        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).activationDidComplete(_:)),
            name: .activationDidComplete, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).reachabilityDidChange(_:)),
            name: .reachabilityDidChange, object: nil
        )
        
        _ = WCSession.default.receivedApplicationContext
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if let context = WCSession.default.receivedApplicationContext as? [String: Any] {
//            self.context = context
//            updateUI(with: context)
//            type(of: self).instances.append(self)
            reloadRootController(with: context)
        }
        
//        updateUI(with: context)
    }
    
    private func reloadRootController(with contexts: [String: Any]) {
//        let names = Array(repeating: ControllerID.mainInterfaceController, count: contexts.count)
        typealias ControllersType = (name: String, context: AnyObject)
        var controllers: [ControllersType] = []
//        for (index, name) in names.enumerated() {
//            controllers += [(name, contexts[index] as AnyObject)]
//        }
        contexts.forEach { (key: String, value: Any) in
            controllers += [(ControllerID.mainInterfaceController, value as AnyObject)]
        }
        
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: controllers)
    }
    
    @objc
    func activationDidComplete(_ notification: Notification) {
        print("\(#function): activationState:\(WCSession.default.activationState.rawValue)")
    }

    @objc
    func reachabilityDidChange(_ notification: Notification) {
        print("\(#function): isReachable:\(WCSession.default.isReachable)")
    }
    
    @objc
    func dataDidFlow(_ notification: Notification) {
        guard let commandStatus = notification.object as? CommandStatus else { return }
        guard commandStatus.command == .updateAppContext else { return }
        
        reloadRootController(with: commandStatus.model.orEmpty())
//        if commandStatus.command == context?.command {
//            updateUI(with: commandStatus, errorMessage: commandStatus.errorMessage)
//        }
//        } else if let index = type(of: self).instances.firstIndex(where: { $0.context?.command == commandStatus.command }) {
//            let controller = TrainingInterfaceController.instances[index]
//            controller.becomeCurrentPage()
//            controller.updateUI(with: commandStatus, errorMessage: commandStatus.errorMessage)
//        }
    }
}
