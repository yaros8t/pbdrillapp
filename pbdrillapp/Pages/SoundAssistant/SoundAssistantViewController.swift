import UIKit

final class SoundAssistantViewController: BaseDrillViewController {
    
    @IBOutlet private var timeTitleLabel: UILabel!
    @IBOutlet private var firstTagsLabel: UILabel!
    @IBOutlet private var firstTagsView: EYTagView!
    @IBOutlet private var secondTagsLabel: UILabel!
    @IBOutlet private var secondTagsView: EYTagView!
    
    private var model: SoundAssistantModel!
    private var drillTimeView: TimeView?
    private var repeatsTimeView: TimeView?

    private lazy var service: SoundAssistantService = SoundAssistantService(delegate: self, dataSource: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "sound_timer".localized
        timeTitleLabel.text = ""
        firstTagsLabel.text = "random_tags_1".localized
        secondTagsLabel.text = "random_tags_2".localized

        model = storage.getSoundAssistantModel()
        drillTimeView = addTimeView(with: model.drill)
        repeatsTimeView = addTimeView(with: model.repeats)
        
        prepareTagView(firstTagsView)
        prepareTagView(secondTagsView)
        firstTagsView.addTags(model.firstTags)
        secondTagsView.addTags(model.secondTags)
        
        resetTimeLabel()
    }

    override func start() {
        super.start()
        service.start(with: model)
    }

    override func stop() {
        super.stop()
        service.stop()
        drillTimeView?.backgroundColor = .clear
        
        resetTimeLabel()
    }
    
    private func prepareTagView(_ tagView: EYTagView) {
        tagView.backgroundColor = .clear
        tagView.colorTag = UIColor(named: "tagText")
        tagView.colorTagBg = UIColor(named: "tagBackground")
        tagView.colorInputBg = UIColor(named: "tagBackground")
        tagView.colorInputPlaceholder = UIColor(named: "tagText")
        tagView.colorInputBoard = UIColor(named: "tagBoard")
        tagView.colorInput = UIColor(named: "tagText")
        tagView.delegate = self
        
        tagView.layoutTagviews()
    }

    override func save(_ time: TimeModel?) {
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
    }
    
    private func resetTimeLabel() {
        timeLabel.text = "\(model.drill.value) " + "s".localized
    }
    
    private func saveModel() {
        model.firstTags = firstTagsView.tagStrings() as! [String]
        model.secondTags = secondTagsView.tagStrings() as! [String]
        storage.save(settings: model)
    }
}

extension SoundAssistantViewController: EYTagViewDelegate {
    
    func tagDidBeginEditing(_ tagView: EYTagView!) {
        stop()
    }
    
    func tagDidEndEditing(_ tagView: EYTagView!) {
        saveModel()
    }
    
    func willRemoveTag(_ tagView: EYTagView!, index: Int) -> Bool {
        return true
    }
    
    func didRemoveTag(_ tagView: EYTagView!, index: Int) {
        saveModel()
    }
}

extension SoundAssistantViewController: SoundAssistantServiceDelegate {

    func soundAssistantService(_ service: SoundAssistantService, didUpdateDrill time: Int) {
        setTimeValue(time)
        
        UIView.animate(withDuration: 0.3) {
            self.drillTimeView?.backgroundColor = UIColor(named: "timeHighlight")
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
