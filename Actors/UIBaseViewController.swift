//
//  UIBaseViewController.swift
//  EventX
//
//  Created by YuCheng on 2018/11/11.
//  Copyright © 2018 EventXtra. All rights reserved.
//

import SwiftUI

class UIBaseViewController: UIViewController {

    @IBOutlet public weak var baseNavigationBar: UIView?
    @IBOutlet public weak var navTitleLabel: UILabel?
    @IBOutlet public weak var navLeftButton: UIButton?
    @IBOutlet private weak var containerView: UIView?
    @IBOutlet private weak var navBarHeightConstraint: NSLayoutConstraint?

    var childVC: UIViewController? = nil

    var navButtonClickActionSelector: Selector?
    var buttonClickActionSelector: Selector?
    var defaultNavHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        if childVC != nil {
            for vc in self.children {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            self.addChild(childVC!)
            let childView = childVC?.view
            childView?.translatesAutoresizingMaskIntoConstraints = false
            containerView?.addSubview(childVC!.view)
            containerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[childView]-|", options: [], metrics: nil, views: ["childView" : childView!]))
            containerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[childView]-|", options: [], metrics: nil, views: ["childView" : childView!]))
            childVC?.didMove(toParent: self)
        }
    }

    // MARK: - public
    public final func baseContainerView() -> UIView {
        return containerView!
    }

    public final func basePushToViewController(_ viewController: UIViewController, Animated anmated: Bool) {
        let newBaseVC: UIBaseViewController = self.storyboard?.instantiateViewController(withIdentifier: self.restorationIdentifier!) as? UIBaseViewController ?? UIBaseViewController()
        newBaseVC.childVC = viewController
        self.navigationController?.pushViewController(newBaseVC, animated: anmated)
    }

    public final func basePresentViewController(_ viewController: UIViewController, Animated anmated: Bool) {
        let newBaseVC: UIBaseViewController = self.storyboard?.instantiateViewController(withIdentifier: self.restorationIdentifier!) as? UIBaseViewController ?? UIBaseViewController()
        newBaseVC.childVC = viewController
        self.present(newBaseVC, animated: anmated, completion: nil)
    }

    public final func hideBaseNavigationBar() {
        navBarHeightConstraint?.constant = 0
        baseNavigationBar?.isHidden = true
    }

    public final func displayBaseNavigationBar() {
        navBarHeightConstraint?.constant = defaultNavHeight!
        baseNavigationBar?.isHidden = false
    }

    // MARK: - public
    public final func addTarget(_ aTarget: Any, navButtonClickAction selector: Selector) {
        navButtonClickActionSelector = selector
        if childVC == nil {
            childVC = aTarget as? UIViewController
        }
    }

    public final func addTarget(_ aTarget: Any, buttonClickAction selector: Selector) {
        buttonClickActionSelector = selector
        if childVC == nil {
            childVC = aTarget as? UIViewController
        }
    }

    // MARK: - action
    @IBAction func navButtonClickAction(_ sender: UIButton) {
        if navButtonClickActionSelector != nil && (childVC?.responds(to: navButtonClickActionSelector))! {
            // clang diagnostic push
            // clang diagnostic ignored "-Warc-performSelector-leaks"
            childVC?.performSelector(inBackground: navButtonClickActionSelector!, with: sender)
            // clang diagnostic pop
        } else {
            if (self.presentingViewController != nil) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }

    @IBAction func buttonClickAction(_ sender: UIButton) {
        if buttonClickActionSelector != nil && (childVC?.responds(to: buttonClickActionSelector))! {
            // clang diagnostic push
            // clang diagnostic ignored "-Warc-performSelector-leaks"
            childVC?.performSelector(inBackground: buttonClickActionSelector!, with: sender)
            // clang diagnostic pop
        }
    }
}
