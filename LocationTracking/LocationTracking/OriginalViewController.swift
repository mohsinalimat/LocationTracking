//
//  OriginalViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import RappleProgressHUD

class OriginalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = Common.mainColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UINavigation Bar
    func addLeftBarItem(imageName : String, title : String) {
        let leftButton = UIButton.init(type: UIButtonType.custom)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        leftButton.addTarget(self, action: #selector(tappedLeftBarButton(sender:)), for: UIControlEvents.touchUpInside)
        if title.characters.count > 0 {
            leftButton.setTitle(title, for: UIControlState.normal)
        }
        if imageName.characters.count > 0 {
            leftButton.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftButton)
    }
    
    func addRightBarItem(imageName : String, title : String) {
        let rightButton = UIButton.init(type: UIButtonType.custom)
        rightButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        rightButton.addTarget(self, action: #selector(tappedRightBarButton(sender:)), for: UIControlEvents.touchUpInside)
        if title.characters.count > 0 {
            rightButton.setTitle(title, for: UIControlState.normal)
        }
        if imageName.characters.count > 0 {
            rightButton.setImage(UIImage.init(named: imageName), for: UIControlState.normal)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
    }

    func addTitleNavigation(title : String) {
        let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screen_width - 120, height: 44))
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
        self.navigationItem.titleView = titleLabel
    }
    
    //MARK: - Action
    func tappedLeftBarButton(sender : UIButton) {
        
    }

    func tappedRightBarButton(sender : UIButton) {
        
    }
    
    //MARK: - Function
    
    func showHUD() {
        RappleActivityIndicatorView.startAnimating()
    }
    
    func hideHUD() {
        RappleActivityIndicatorView.stopAnimation()
    }
}
