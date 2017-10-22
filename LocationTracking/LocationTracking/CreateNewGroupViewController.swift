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
    var contactArray = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
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
        self.getContactList()
    }
    
    //MARK: - Action
    override func tappedRightBarButton(sender: UIButton) {
        self.showHUD()
        if (groupNameTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.createGroup(name: groupNameTextField.text!, array: selectedContactArray)
            self.hideHUD()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.hideHUD()
            view.makeToast("Please input group name.", duration: 2.0, position: .center)
        }
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Get contact list
    func getContactList() {
        contactArray += DatabaseManager.getContactSharedLocation(contetxt: nil)
        tableView.reloadData()
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
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setupCell(contact: contactArray[indexPath.row])
        return cell
    }
    
    //MARK: - Cell Delegate
    func saveGroup(indexPath: IndexPath) {
        let contact: Contact = contactArray[indexPath.row]
        selectedContactArray.append(contact.id!)
    }
}
