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
         initController("SoundAssistantViewController"),
         initController("FeedbackViewController")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.addTarget(self, action: #selector(didChangePageControlValue), for: .valueChanged)

        hideConfirmView(animated: false)
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

    private func showConfitmView() {
        confirmViewBottomConstraint.constant = 4
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func hideConfirmView(animated _: Bool = true) {
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
        
        if model.id == TimeModel.drillPauseTime.id {
            confirmView.titlelabel.text = "Pause time"
            confirmView.descLabel.text = "Pause time between sets. This time is announced by the voice assistant"
        } else if model.id == TimeModel.drillTime.id {
            confirmView.titlelabel.text = "Drill time"
            confirmView.descLabel.text = "Time to complete the exercise"
        } else if model.id == TimeModel.drillRepeats.id {
            confirmView.titlelabel.text = "Repeats count"
            confirmView.descLabel.text = "The number of repetitions of the exercises. When finished, the end tone will sound"
            
        } else if model.id == TimeModel.gameWait.id {
            confirmView.titlelabel.text = "Wait time"
            confirmView.descLabel.text = "Time before the start of the game"
        } else if model.id == TimeModel.gameLimit.id {
            confirmView.titlelabel.text = "Limit time"
            confirmView.descLabel.text = "Game completion time. If you put 0, then there will be no time limit"
            
        } else if model.id == TimeModel.saDrillTime.id {
            confirmView.titlelabel.text = "Drill time"
            confirmView.descLabel.text = "Time to complete the exercise"
        } else if model.id == TimeModel.saRepeatsTime.id {
            confirmView.titlelabel.text = "Repeats count"
            confirmView.descLabel.text = "The number of repetitions of the exercises. When finished, the end tone will sound"
        }
 
        showConfitmView()
        controller.changeMode(.edit)

        confirmView.doneAction = {
            controller.applyNewValue()
        }
        confirmView.cancelAction = {
            controller.cancelNewValue()
        }
    }

    func drillViewController(_ controller: BaseDrillViewController, didEndEditMode _: TimeModel) {
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
