//
//  DebugWindow.swift
//  DebugWindowKit
//
//  Created by Ryan Moniz on 1/2/19.
//  Copyright © 2019 Ryan Moniz. All rights reserved.
//

//Since DebugWindow is primarily a debugging library and should never be included in production, the steps below will outline how to install DebugWindow in a way that keeps it out of production builds. There is also a guide below explaining how to verify which builds have DebugWindow and which ones do not.




import UIKit
import CoreData
import netfox_ios

public class DebugWindow {
    public static let sharedInstance = DebugWindow()
    
    private var _menuItems = [DWGenericMenu]()
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    private var debugVC: DebugTableViewController!
    
    public var managedObjectModel: NSManagedObjectModel?
    public var context: NSManagedObjectContext?
    public var moduleName: String?
    public var startNetfox: Bool = false {
        didSet {
            if startNetfox {
                NFX.sharedInstance().start()
            } else {
                NFX.sharedInstance().stop()
            }
        }
    }
    
    //MARK: - Methods
    
    public func setup(menuItems:[DWGenericMenu]?) {
        NSLog("DebugWindow init")
        
        if let newMenuItems = menuItems {
            self._menuItems = newMenuItems
        }
        
        //configure swipe action
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedScreen))
        swipeGesture.direction = UISwipeGestureRecognizer.Direction.right
        swipeGesture.numberOfTouchesRequired = 3
        
        if let window = UIApplication.shared.delegate?.window {
            window?.addGestureRecognizer(swipeGesture)
        } else {
            NSLog("ERROR: app has no window defined in AppDelegate????")
        }
    }
    
    public func showDebugView(parentViewController: UIViewController) {
        let storyboardName = "DebugTableViewController"
        let sbBundle = Bundle(for: DebugWindow.self)
        let sb = UIStoryboard(name: storyboardName, bundle: sbBundle)
        
        guard let debugNavVC = sb.instantiateInitialViewController() as? UINavigationController else {
            NSLog("ERROR: missing DebugTableViewController storyboard/initalizer")
            return
        }
        
        if let debugVC = debugNavVC.viewControllers.first as? DebugTableViewController {
            debugVC._menuItems = self._menuItems
            debugNavVC.viewControllers = [debugVC]
        }
        
        //configure uipresentationcontroller
        slideInTransitioningDelegate.direction = .left
        slideInTransitioningDelegate.disableCompactHeight = false
        //debugNavVC.transitioningDelegate = slideInTransitioningDelegate
        debugNavVC.modalPresentationStyle = .overCurrentContext//.custom
        
        //present debug view
        parentViewController.present(debugNavVC, animated: true, completion: nil)
    }

    
    public func showDebugView() {
        let storyboardName = "DebugTableViewController"
        let sbBundle = Bundle(for: DebugWindow.self)
        let sb = UIStoryboard(name: storyboardName, bundle: sbBundle)
        
        guard let debugNavVC = sb.instantiateInitialViewController() as? UINavigationController else {
            NSLog("ERROR: missing DebugTableViewController storyboard/initalizer")
            return
        }
        
        if let debugVC = debugNavVC.viewControllers.first as? DebugTableViewController {
            debugVC._menuItems = self._menuItems
            debugNavVC.viewControllers = [debugVC]
        }
        
        //configure uipresentationcontroller
        slideInTransitioningDelegate.direction = .left
        slideInTransitioningDelegate.disableCompactHeight = false
        debugNavVC.transitioningDelegate = slideInTransitioningDelegate
        debugNavVC.modalPresentationStyle = .custom
        
        //present debug view
        if let window = UIApplication.shared.delegate?.window {
            window?.rootViewController?.present(debugNavVC, animated: true, completion: nil)
        } else {
            NSLog("ERROR: app has no window defined in AppDelegate????")
        }
    }
    
    @objc private func swipedScreen(swipeGesture:UISwipeGestureRecognizer) {
        NSLog("swipedScreen called")
        
        showDebugView()
    }
}
