//
//  RootViewController.swift
//  DrillTimers
//
//  Created by Yaroslav Tytarenko on 11.06.2020.
//  Copyright © 2020 Yaros H. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {
    
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet private var confirmView: ConfirmView!
    @IBOutlet private var confirmViewBottomConstraint: NSLayoutConstraint!

    private var pagesViewController: PagesViewController? {
        didSet {
            pagesViewController?.pagesDelegate = self
        }
    }
    
    private lazy var drillControllers: [BaseDrillViewController] = {
        [initController("DrillViewController"),
         initController("GameViewController"),
         initController("RandAssistantViewController"),
         initController("FeedbackViewController")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: .valueChanged)
        
        hideConfirmView(animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pagesViewController = segue.destination as? PagesViewController {
            self.pagesViewController = pagesViewController
            self.pagesViewController?.orderedViewControllers = drillControllers
        }
    }

    @IBAction func didTapNextButton(_ sender: Any) {
        pagesViewController?.scrollToNextViewController()
    }

    @objc func didChangePageControlValue() {
        pagesViewController?.scrollToViewController(index: pageControl.currentPage)
    }
    
    private func showConfitmView() {
        confirmViewBottomConstraint.constant = 4
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideConfirmView(animated: Bool = true) {
        confirmViewBottomConstraint.constant = -300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func initController(_ name: String) -> BaseDrillViewController {
        let base = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! BaseDrillViewController
        base.delegate = self
        return base
    }
}

extension RootViewController: PagesViewControllerDelegate {
    func pagesViewController(pagesViewController: PagesViewController,didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func pagesViewController(pagesViewController: PagesViewController,didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}

extension RootViewController: BaseDrillViewControllerDelegate {
    func drillViewController(_ controller: BaseDrillViewController, didStartEditMode model: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = false
        showConfitmView()
        controller.changeMode(.edit)
        
        confirmView.doneAction = {
            controller.applyNewValue()
        }
        confirmView.cancelAction = {
            controller.cancelNewValue()
        }
    }
    
    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode model: TimeModel) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        pagesViewController?.isPagingEnabled = true
        hideConfirmView()
        controller.changeMode(.regular)
        
        confirmView.doneAction = nil
        confirmView.cancelAction = nil
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
