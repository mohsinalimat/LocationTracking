//
//  OriginalViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import RappleProgressHUD

class OriginalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var progressHUD: ProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = Common.mainColor()
        self.registerKeyboardEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UINavigation Bar
    func addLeftBarItem(imageName : String, title : String) {
        let leftButton = UIButton.init(type: UIButtonType.custom)
        leftButton.isExclusiveTouch = true
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        leftButton.addTarget(self, action: #selector(tappedLeftBarButton(sender:)), for: UIControlEvents.touchUpInside)
        if title.count > 0 {
            leftButton.setTitle(title, for: UIControlState.normal)
        }
        if imageName.count > 0 {
            leftButton.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftButton)
    }
    
    func addRightBarItem(imageName : String, title : String) {
        let rightButton = UIButton.init(type: UIButtonType.custom)
        rightButton.isExclusiveTouch = true
        rightButton.addTarget(self, action: #selector(tappedRightBarButton(sender:)), for: UIControlEvents.touchUpInside)
        if title.count > 0 {
            rightButton.frame = CGRect.init(x: 0, y: 0, width: 80, height: 30)
            rightButton.setTitle(title, for: UIControlState.normal)
            rightButton.setupBorder()
        }
        if imageName.count > 0 {
            rightButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
            rightButton.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
    }

    func addTitleNavigation(title : String) {
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screen_width - 120, height: 44))
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        
        self.navigationItem.titleView = titleLabel
    }
    
    func addButtonTitle(title : String) {
        let titleButton = UIButton.init(type: .custom)
        titleButton.isExclusiveTouch = true
        titleButton.frame = CGRect.init(x: 0, y: 0, width: screen_width - 120, height: 44)
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        titleButton.titleLabel?.numberOfLines = 2
        titleButton.setTitle(title, for: .normal)
        titleButton.addTarget(self, action: #selector(tappedTitleButton), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
    }
    
    //MARK: - Observe
    func registerKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEventWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEventWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func removeObserve() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardEventWillShow(_ notification: Notification) {
    }
    
    func keyboardEventWillHide(_ notification: Notification) {
    }
    
    //MARK: - Action
    func tappedLeftBarButton(sender : UIButton) {
        
    }

    func tappedRightBarButton(sender : UIButton) {
        
    }
    
    func tappedTitleButton() {
        
    }
    
    func tappedCancelAddingLocation() {
        
    }
    
    //MARK: - Function
    
    func showHUD() {
        RappleActivityIndicatorView.startAnimating()
    }
    
    func hideHUD() {
        RappleActivityIndicatorView.stopAnimation()
    }
    
    func showProgress(title: String) {
        progressHUD = ProgressView(text: title)
        self.navigationController?.view.addSubview(progressHUD!)
    }
    
    func hideProgress() {
        progressHUD?.removeFromSuperview()
    }
    
    func showAlert(title: String, message: String, cancelTitle: String, okTitle: String, onOKAction:@escaping () -> ()) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        if cancelTitle.count > 0 {
            alert.addAction(UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.cancel, handler: nil))
        }
        
        if okTitle.count > 0 {
            alert.addAction(UIAlertAction(title: okTitle, style: UIAlertActionStyle.default, handler: {_ in
                onOKAction()
            }))
        }
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(titleArray: [String], onTapped: @escaping (String) -> ()) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for title in titleArray {
            actionSheetController.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: {_ in
                onTapped(title)
            }))
        }
        
        actionSheetController.addAction(UIAlertAction(title: LocalizedString(key: "CANCEL"), style: UIAlertActionStyle.cancel, handler: nil))
        self.present(actionSheetController, animated: true, completion: nil)
    }
}
