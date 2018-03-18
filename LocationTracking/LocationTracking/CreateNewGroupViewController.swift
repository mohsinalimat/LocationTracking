//
//  CreateNewGroupViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 10/16/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class CreateNewGroupViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, createGroupDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    var selectedContactArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
        selectedContactArray.append(app_delegate.profile.id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SetupUI
    func setupNavigationBar() {
        self.addLeftBarItem(imageName: "ico_back",title: "")
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: "Add new group")
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        //Get contact list
        tableView.reloadData()
    }
    
    //MARK: - Action
    override func tappedRightBarButton(sender: UIButton) {
        if (groupNameTextField.text?.count)! > 0 {
            
            if selectedContactArray.count < 2 {
                view.makeToast("Please add contact to this group!", duration: 2.0, position: .center)
                return
            }
            self.showHUD()
            app_delegate.firebaseObject.createGroup(name: groupNameTextField.text!, array: selectedContactArray, onCompletionHandler: {
                self.hideHUD()
                self.navigationController?.popViewController(animated: true)
            })
            
        } else {
            view.makeToast("Please input group name!", duration: 2.0, position: .center)
        }
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        return sharedContactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewGroupTableViewCell") as! CreateNewGroupTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        cell.setupCell(contact: sharedContactArray[indexPath.row])
        return cell
    }
    
    //MARK: - Cell Delegate
    func addToGroup(indexPath: IndexPath) {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        let contact: ContactModel = sharedContactArray[indexPath.row]
        selectedContactArray.append(contact.id)
    }
    
    func deleteFromGroup(indexPath: IndexPath) {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        let contact: ContactModel = sharedContactArray[indexPath.row]
        selectedContactArray = selectedContactArray.filter{$0 != contact.id}
    }
}
