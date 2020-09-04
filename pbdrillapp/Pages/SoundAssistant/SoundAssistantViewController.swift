import UIKit

class SoundAssistantViewController: BaseDrillViewController {
    
    @IBOutlet private var firstTagsView: EYTagView!
    @IBOutlet private var secondTagsView: EYTagView!
    
    private var model: SoundAssistantModel!
    private var drillTimeView: TimeView?
    private var repeatsTimeView: TimeView?

    private lazy var service: SoundAssistantService = SoundAssistantService(delegate: self, dataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        model = storage.getSoundAssistantModel()
        drillTimeView = addTimeView(with: model.drill)
        repeatsTimeView = addTimeView(with: model.repeats)

        hideTimeLabel()
        runButton.delegate = self
        
        prepareTagView(firstTagsView)
        prepareTagView(secondTagsView)
        firstTagsView.addTags(model.firstTags)
        secondTagsView.addTags(model.secondTags)
    }

    override func changeMode(_ mode: BaseDrillViewController.Mode) {
        guard self.mode != mode else { return }

        self.mode = mode

        if mode == .edit {
            stop()
            firstTagsView.alpha = 0
            secondTagsView.alpha = 0
            startEditMode(selectedTimeView!)
            delegate?.drillViewController(self, didStartEditMode: selectedTimeView!.model!)
        } else {
            endEditMode()
            delegate?.drillViewController(self, didEndEditMode: selectedTimeView!.model!)
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseInOut]) {
                self.firstTagsView.alpha = 1
                self.secondTagsView.alpha = 1
            }
        }
    }

    override func applyNewValue() {
        save(selectedTime)
        changeMode(.regular)
    }

    override func cancelNewValue() {
        selectedTime = nil
        changeMode(.regular)
    }

    override func start() {
        super.start()
        service.start(with: model)
    }

    override func stop() {
        super.stop()
        service.stop()
        drillTimeView?.backgroundColor = .clear
    }
    
    private func prepareTagView(_ tagView: EYTagView) {
        tagView.fontTag = UIFont.systemFont(ofSize: 14)
        tagView.fontInput = UIFont.systemFont(ofSize: 14)
        tagView.colorTag = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tagView.colorTagBg = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        tagView.colorInputBg = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tagView.colorInputPlaceholder = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tagView.colorInputBoard = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        tagView.colorInput = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tagView.delegate = self
    }

    private func save(_ time: TimeModel?) {
        guard let time = time else { assert(false); return }

        if time.id == model.drill.id {
            model.drill = time
            drillTimeView?.setup(model: time)
        } else if time.id == model.repeats.id {
            model.repeats = time
            repeatsTimeView?.setup(model: time)
        } else {
            assert(false)
        }

        storage.save(settings: model)

        hideTimeLabel()
    }
}

extension SoundAssistantViewController: EYTagViewDelegate {
    
    func tagDidBeginEditing(_ tagView: EYTagView!) {
        stop()
    }
}

extension SoundAssistantViewController: SoundAssistantServiceDelegate {

    func soundAssistantService(_ service: SoundAssistantService, didUpdateDrill time: Int) {
        setTimeValue(time)
        
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }

    func soundAssistantService(_ service: SoundAssistantService, didUpdateRepeats time: Int) {
        repeatsTimeView?.update(value: "\(time)")
    }

    func soundAssistantServiceDidEnd() {
        super.stop()
        self.drillTimeView?.backgroundColor = .clear
    }
}

extension SoundAssistantViewController: SoundAssistantServiceDataSource {
    func firstTags() -> [String] {
        firstTagsView.tagStrings() as! [String]
    }
    
    func secondTags() -> [String] {
        secondTagsView.tagStrings() as! [String]
    }
}

extension SoundAssistantViewController: RunButtonDelegate {
    
    func didChangeValue(_ value: Int) {
        guard let model = selectedTimeView?.model else { assert(false); return }
        selectedTime = model
        selectedTime?.value = value
        setTimeValue(value)
    }

    func runButtonDidTap() {
        guard mode != .edit else { return }

        if isRunned {
            stop()
        } else {
            start()
        }
    }
}

