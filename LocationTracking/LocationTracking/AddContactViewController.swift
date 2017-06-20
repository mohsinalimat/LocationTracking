//
//  AddContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/20/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class AddContactViewController: OriginalViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextView: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        app_delegate.firebaseObject.searchContactWithEmail(id: , email: <#T##String#>)
    }
}
