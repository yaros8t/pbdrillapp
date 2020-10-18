import UIKit

final class RootViewController: UIViewController {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var containerView: UIView!

    private var pagesViewController: PagesViewController? {
        didSet {
            pagesViewController?.pagesDelegate = self
        }
    }

    private lazy var drillControllers: [BaseDrillViewController] = {
        [initController("DrillViewController"),
         initController("GameViewController"),
         initController("SoundAssistantViewController"),
         initController("FeedbackViewController")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: .valueChanged)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let pagesViewController = segue.destination as? PagesViewController {
            self.pagesViewController = pagesViewController
            self.pagesViewController?.orderedViewControllers = drillControllers
        }
    }

    @IBAction func didTapNextButton(_: Any) {
        pagesViewController?.scrollToNextViewController()
    }

    @objc func didChangePageControlValue() {
        pagesViewController?.scrollToViewController(index: pageControl.currentPage)
    }

    private func initController(_ name: String) -> BaseDrillViewController {
        let base = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! BaseDrillViewController
        base.delegate = self
        return base
    }
}

extension RootViewController: PagesViewControllerDelegate {
    func pagesViewController(pagesViewController _: PagesViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func pagesViewController(pagesViewController _: PagesViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}

extension RootViewController: BaseDrillViewControllerDelegate {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = false
    }

    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode _: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = true
    }

    func drillViewControllerDidStartTimer() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = false
    }

    func drillViewControllerDidStopTimer() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = true
    }
}
