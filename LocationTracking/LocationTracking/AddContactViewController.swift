//
//  AddContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/20/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class AddContactViewController: OriginalViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var contactArray = [ContactModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    @IBAction func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContactTableViewCell") as! SearchContactTableViewCell
        cell.setupCell(contact: contactArray[indexPath.row])
        return cell
    }
}
