import Foundation
import WatchKit
import WatchConnectivity

struct ControllerID {
    static let mainInterfaceController = "TrainingInterfaceController"
}

final class TrainingInterfaceController: WKInterfaceController, SessionCommands {
    
    @IBOutlet private var titleLabel: WKInterfaceLabel!
    @IBOutlet private var timeLabel: WKInterfaceTimer!
    @IBOutlet private var settingsGroup: WKInterfaceGroup!
    @IBOutlet private var commandButton: WKInterfaceButton!
    
    @IBOutlet private var optionLabel1: WKInterfaceLabel!
    @IBOutlet private var optionLabel2: WKInterfaceLabel!
    @IBOutlet private var optionLabel3: WKInterfaceLabel!
    
    private static var instances = [TrainingInterfaceController]()
    private var context: CommandStatus?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let context = context as? CommandStatus {
            self.context = context
            updateUI(with: context)
            type(of: self).instances.append(self)
        } else {
            titleLabel.setText("Activating...")
            reloadRootController()
        }

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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willActivate() {
        super.willActivate()
        
        updateUI(with: context)
    }
    
    private func reloadRootController(with currentContext: CommandStatus? = nil) {
        let commands: [Command] = [.updateDrillTimerState, .updateGameTimerState, .updateSoundTimerState]
        var contexts = [CommandStatus]()
        for aCommand in commands {
            var commandStatus = CommandStatus(command: aCommand, phrase: .finished)
            if let currentContext = currentContext, aCommand == currentContext.command {
                commandStatus.phrase = currentContext.phrase
                commandStatus.model = currentContext.model
            }
            contexts.append(commandStatus)
        }
        
        let names = Array(repeating: ControllerID.mainInterfaceController, count: contexts.count)
        typealias ControllersType = (name: String, context: AnyObject)
        var controllers: [ControllersType] = []
        for (index, name) in names.enumerated() {
            controllers += [(name, contexts[index] as AnyObject)]
        }
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: controllers)
    }
    
    @objc
    func dataDidFlow(_ notification: Notification) {
        guard let commandStatus = notification.object as? CommandStatus else { return }

        if commandStatus.command == context?.command {
            updateUI(with: commandStatus, errorMessage: commandStatus.errorMessage)
            
        } else if let index = type(of: self).instances.firstIndex(where: { $0.context?.command == commandStatus.command }) {
            let controller = TrainingInterfaceController.instances[index]
            controller.becomeCurrentPage()
            controller.updateUI(with: commandStatus, errorMessage: commandStatus.errorMessage)
        }
    }

    @objc
    func activationDidComplete(_ notification: Notification) {
        print("\(#function): activationState:\(WCSession.default.activationState.rawValue)")
    }

    @objc
    func reachabilityDidChange(_ notification: Notification) {
        print("\(#function): isReachable:\(WCSession.default.isReachable)")
    }
    
    @IBAction func commandAction() {
        guard let command = context?.command else { return }
        guard let model = context?.model else { return }
        
        switch command {
        case .updateDrillTimerState:
            updateDrillTimerState(model)
        case .updateGameTimerState:
            updateGameTimerState(model)
        case .updateSoundTimerState:
            updateSoundTimerState(model)
        case .updateAppContext:
            updateAppContext(model)
        }
    }
}

extension TrainingInterfaceController {

    private func updateUI(with commandStatus: CommandStatus?, errorMessage: String? = nil) {
        guard let commandStatus = commandStatus else { return }
        
        switch commandStatus.command {
        case .updateAppContext:
            break
        case .updateDrillTimerState, .updateGameTimerState, .updateSoundTimerState:
            Parser<DrillModel>.parse(commandStatus.model.orEmpty()) { model in
                
                switch model.type {
                case .training:
                    self.optionLabel1.setText("D: \(model.drillTime.value)s")
                    self.optionLabel2.setText("P: \(model.drillPauseTime.value)s")
                    self.optionLabel3.setText("R: \(model.drillRepeats.value)times")
                case .game:
                    self.optionLabel1.setText("W: \(model.gameWait.value)s")
                    self.optionLabel2.setText("L: \(model.gameLimit.value)s")
                    self.optionLabel3.setHidden(true)
                case .rand:
                    self.optionLabel1.setText("D: \(model.saDrillTime.value)s")
                    self.optionLabel2.setText("R: \(model.saRepeatsTime.value)times")
                    self.optionLabel3.setHidden(true)
                }
//                Formater.secondsToHoursMinutesSeconds(interval: value)
                self.titleLabel.setText(model.type.name)
//                self.timeLabel.setText(model.tim)
            }
        }
    }
}
