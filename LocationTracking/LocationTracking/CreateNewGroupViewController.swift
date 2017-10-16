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
    var contactNameArray = [String]()
    var contactArray = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: "Add new group")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        if (groupNameTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.createGroup(name: groupNameTextField.text!, array: contactNameArray)
        } else {
            view.makeToast("Please input group name.", duration: 2.0, position: .center)
        }
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewGroupTableViewCell") as! CreateNewGroupTableViewCell
        return cell
    }
}
