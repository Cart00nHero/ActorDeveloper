//
//  UIFreePresentationController.swift
//  UIFreeSizePresentationController
//
//  Created by YuCheng on 2021/3/10.
//

import Foundation
import UIKit

class UIFreePresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = presentingViewController.view.bounds
		let width = UIScreen.main.bounds.height * 0.99999999
        let size = CGSize(width: width, height: width)
        let origin = CGPoint(
            x: bounds.midX - size.width / 2.0, y: bounds.midY - size.height / 2.0)
        return CGRect(origin: origin, size: size)
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedView?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin
        ]
        
        presentedView?.translatesAutoresizingMaskIntoConstraints = true
    }
    
    let dimmingView: UIView = {
//		let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		let dimmingView = UIView()
		dimmingView.backgroundColor = UIColor.black
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        let superview = presentingViewController.view!
        superview.addSubview(dimmingView)
		if #available(iOS 9.0, *) {
			NSLayoutConstraint.activate([
				dimmingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
				dimmingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
				dimmingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
				dimmingView.topAnchor.constraint(equalTo: superview.topAnchor)
			])
		} else {
			// Fallback on earlier versions
		}
        
        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			self.dimmingView.alpha = 0.5
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return UIFreePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
