//
//  CreateNewGroupViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 10/16/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class CreateNewGroupViewController: OriginalViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    var memberArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: "Add new group")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        if (groupNameTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.createGroup(name: groupNameTextField.text!, array: memberArray)
        } else {
            view.makeToast("Please input group name.", duration: 2.0, position: .center)
        }
    }
}
