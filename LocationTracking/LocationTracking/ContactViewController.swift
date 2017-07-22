//
//  ContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/15/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ContactViewController : OriginalViewController,UITableViewDelegate,UITableViewDataSource,ContactTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var contactArray = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTitleNavigation(title: "Contact List")
        self.initView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init Object
    func initView() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    //MARK: - Data
    func initData() {
        contactArray.removeAll()
        contactArray += DatabaseManager.getAllContact()
        tableView.reloadData()
    }
    //MARK: - Action
    @IBAction func tappedSignOut(_ sender: UIButton) {
        let result = app_delegate.firebaseObject.signOut()
        if result {
            //Sign out is success
            if let drawerController = self.parent?.parent as? KYDrawerController {
                drawerController .dismiss(animated: true, completion: nil)
            }
        } else {
            //Sign out is failure
        }
    }
    
    //MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.setupCell(contact: contactArray[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Show Map View
        if let drawerController = self.parent?.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            let mapNavigationViewController = drawerController.mainViewController as! UINavigationController
            let mapViewController = mapNavigationViewController.viewControllers.last as! MapViewController
            mapViewController.currentContact = contactArray[indexPath.row]
            //Add observer when changed contact
            mapViewController.referentCurrentContact(contactId: (mapViewController.currentContact?.id)!)
        }
    }
    
    //MARK: - ContactTableViewCell Delegate
    func requestLocation(contact: Contact) {
        self .showHUD()
        app_delegate.firebaseObject.requestLocation(toContact: contact, onCompletetionHandler: {_ in
            self.hideHUD()
            DatabaseManager.updateContact(id: contact.id!, latitude: contact.latitude, longitude: contact.longitude, isShare: ShareStatus.kwaitingShared.rawValue, onCompletion: {_ in
                
            })
        })
    }
}
