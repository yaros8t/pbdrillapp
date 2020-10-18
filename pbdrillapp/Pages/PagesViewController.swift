import UIKit

protocol PagesViewControllerDelegate: class {
    func pagesViewController(pagesViewController: PagesViewController, didUpdatePageCount count: Int)
    func pagesViewController(pagesViewController: PagesViewController, didUpdatePageIndex index: Int)
}

class PagesViewController: UIPageViewController {
    weak var pagesDelegate: PagesViewControllerDelegate?
    var orderedViewControllers: [UIViewController] = []

    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }

        pagesDelegate?.pagesViewController(pagesViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }

    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController)
        {
            scrollToViewController(viewController: nextViewController)
        }
    }

    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.firstIndex(of: firstViewController)
        {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }

    private func scrollToViewController(viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController], direction: direction, animated: true, completion: { (_) -> Void in
            self.notifyTutorialDelegateOfNewIndex()
        })
    }

    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first, let index = orderedViewControllers.firstIndex(of: firstViewController) {
            pagesDelegate?.pagesViewController(pagesViewController: self, didUpdatePageIndex: index)
        }
    }
}

extension PagesViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        guard orderedViewControllers.count > previousIndex else { return nil }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else { return orderedViewControllers.first }
        guard orderedViewControllersCount > nextIndex else { return nil }

        return orderedViewControllers[nextIndex]
    }
}

extension PagesViewController: UIPageViewControllerDelegate {
    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
}
