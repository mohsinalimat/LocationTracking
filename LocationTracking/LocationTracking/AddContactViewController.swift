//
//  AddContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/20/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class AddContactViewController: OriginalViewController,UITableViewDelegate,UITableViewDataSource,SearchContactDelegate {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var contactArray = [ContactModel]()
    var selectedContactArray = [ContactModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Layout
    func initLayout() {
        self.addLeftBarItem(imageName: "ico_back",title: "")
        self.addRightBarItem(imageName: "save", title: "")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        searchView.setupBorder()
    }
    
    //MARK: - Action
    @IBAction func tappedSearchContact(_ sender: UIButton) {
        if (searchTextField.text?.characters.count)! > 0 {
            self.showHUD()
            if (searchTextField.text?.characters.count)! > 0 {
                app_delegate.firebaseObject.searchContactWithEmail(email: searchTextField.text!, completionHandler: {(array) in
                    self.contactArray.removeAll()
                    let contactIdList = self.getListContactId()
                    let profile = DatabaseManager.getProfile()
                    
                    if array.count > 0 {
                        for contactModel in array as [ContactModel] {
                            if !((contactIdList?.contains(contactModel.id)))! && profile?.id! != contactModel.id {
                                self.contactArray.append(contactModel)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.hideHUD()
                    }
                })
            }
        }
    }
    
    //Save contact into Favorite
    override func tappedRightBarButton(sender: UIButton) {
        if selectedContactArray.count > 0 {
            self.showHUD()
            DatabaseManager.saveContact(contactArray: selectedContactArray,onCompletion: { _ in
                self.hideHUD()
            //Remove contacts that added to the list
                for contact in self.selectedContactArray {
                    if let ix = self.contactArray.index(of: contact) {
                        self.contactArray.remove(at: ix)
                    }
                }
                self.tableView.reloadData()
            })
        } else {
            view.makeToast("Please choose a account from the list.", duration: 2.0, position: .center)
        }
    }
    
    //Tapped to back
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
       return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContactTableViewCell") as! SearchContactTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setupCell(contact: contactArray[indexPath.row])
        return cell
    }
    
    //MARK: - Cell Delegate
    func SaveContact(indexPath: IndexPath) {
        selectedContactArray.append(contactArray[indexPath.row])
    }
}
