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
        self.addRightBarItem(imageName: "", title: "Save")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        searchView.setupBorder()
    }
    
    //MARK: - Action
    @IBAction func tappedSearchContact(_ sender: UIButton) {
        if (searchTextField.text?.characters.count)! > 0 {
            app_delegate.firebaseObject.searchContactWithEmail(email: searchTextField.text!, completionHandler: {(array) in
                self.contactArray.removeAll()
                self.contactArray.append(contentsOf: array)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    //Save contact into Favorite
    override func tappedRightBarButton(sender: UIButton) {
        self.showHUD()
        DatabaseManager.saveContact(contactArray: selectedContactArray,onCompletion: { _ in
            self.hideHUD()
        })
    }
    
    //Tapped to back
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
