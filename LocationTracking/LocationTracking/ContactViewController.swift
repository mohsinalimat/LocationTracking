//
//  ContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/15/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ContactViewController : OriginalViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var contactArray = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTitleNavigation(title: "Contact List")
        self.addLeftBarItem(imageName: "icon_add_user")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init Object
    func initView() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        //Add new contact
        
    }
    //MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
