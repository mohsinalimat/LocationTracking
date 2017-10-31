//
//  ContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/15/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ContactViewController : OriginalViewController,UITableViewDelegate,UITableViewDataSource,ContactTableViewCellDelegate {

    @IBOutlet weak var shareTwitterButton: UIButton!
    @IBOutlet weak var shareFacebookButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var groupArray = [GroupEntity]()
    var contactArray = [Contact]()
    var currentIndex = kContactListIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.refreshContactData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init Object
    func initView() {
        let profile: Profile! = DatabaseManager.getProfile()
        
        self.addLeftBarItem(imageName: "ic_logout", title: "")
        self.addRightBarItem(imageName: "refresh", title: "")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        self.addButtonTitle(title: profile.email!)
    }
    
    //MARK: - Data
    
    func refreshContactData() {
        switch segmented.selectedSegmentIndex {
        case kContactListIndex:
            contactArray.removeAll()
            contactArray += DatabaseManager.getContactSharedLocation(contetxt: nil)
            tableView.reloadData()
            break
        case kGroupListIndex:
            groupArray.removeAll()
            groupArray += DatabaseManager.getAllGroup(context: nil)
            tableView.reloadData()
            break
        default:
            contactArray.removeAll()
            contactArray += DatabaseManager.getRequestToMeContact(contetxt: nil)
            tableView.reloadData()
            break
        }
    }
    //MARK: - Action
    @IBAction func tappedChangeSegmentedIndex(_ sender: UISegmentedControl) {
        //Only reload when current index != selected index
        if currentIndex != sender.selectedSegmentIndex {
            currentIndex = sender.selectedSegmentIndex
            self.refreshContactData()
        }
    }
    
    @IBAction func tappedShareOnFacebook(_ sender: UIButton) {
    }
    
    @IBAction func tappedShareOnTwitter(_ sender: UIButton) {
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        self.showAlert(title: "", message: "Do you want sign out?", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            let result = app_delegate.firebaseObject.signOut()
            if result {
                //Sign out is success
                if let drawerController = self.parent?.parent as? KYDrawerController {
                    drawerController .dismiss(animated: true, completion: nil)
                }
            } else {
                //Sign out is failure
            }
        })
    }
    
    //Refresh contact from server
    override func tappedRightBarButton(sender: UIButton) {
        self.showHUD()
        let profile = DatabaseManager.getProfile()
        app_delegate.firebaseObject.refreshData(email: (profile?.email)!, name: (profile?.name)!, completionHandler: {isSuccess in
            self.hideHUD()
            self.refreshContactData()
        })
    }
    
    override func tappedTitleButton() {
        let profileViewController = main_storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        self.present(profileViewController, animated: true, completion: {_ in
            if let drawerController = self.parent?.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
            }
        })
    }
    
    //MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showHUD()
            let contact = contactArray[indexPath.row]
            app_delegate.firebaseObject.deleteContact(contactId: contact.id!, atUserId: (app_delegate.profile?.id)!, onCompletionHandler: {_ in
                tableView.beginUpdates()
                self.contactArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .none);
                tableView.endUpdates()
                self.hideHUD()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmented.selectedSegmentIndex == kGroupListIndex {
            return groupArray.count
        }
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        if segmented.selectedSegmentIndex != kGroupListIndex {
            cell.setupCell(contact: contactArray[indexPath.row])
        } else {
            cell.setupGroupCell(group: groupArray[indexPath.row], memberCount: groupArray.count)
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmented.selectedSegmentIndex == kGroupListIndex {
            //Tapped group cell
            self.displayMarker(indexPath: indexPath)
            return
        }
        
        //Tapped contact cell
        let selectedContact = contactArray[indexPath.row]
        if selectedContact.isShare != 0 {
            view.makeToast("Please wait for the user to share the location with you.", duration: 1.5, position: .center)
            return
        }
        self.displayMarker(indexPath: indexPath)
    }
    
    func displayMarker(indexPath: IndexPath) {
        //Show Map View
        if let drawerController = self.parent?.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            let mapNavigationViewController = drawerController.mainViewController as! UINavigationController
            let mapViewController = mapNavigationViewController.viewControllers.last as! MapViewController
            
            mapViewController.currentContactArray.removeAll()
            if segmented.selectedSegmentIndex != kGroupListIndex {
                //Tapped group cell
                mapViewController.currentContact = contactArray[indexPath.row]
                mapViewController.currentContactArray.append(contactArray[indexPath.row])
            } else {
                let sharedContactArray = DatabaseManager.getContactSharedLocation(contetxt: nil)
                let group = groupArray[indexPath.row]
                
                for contact in sharedContactArray! {
                    if (group.member?.contains(contact.id!))! {
                        mapViewController.currentContactArray.append(contact)
                    }
                }
            }
            //Add observer when changed contact
            mapViewController.updateMarker()
        }

    }
    //MARK: - ContactTableViewCell Delegate
    func requestLocation(contact: Contact) {
        self .showHUD()
        app_delegate.firebaseObject.requestLocation(toContact: contact, onCompletetionHandler: {
            DatabaseManager.updateContact(id: contact.id!, name: contact.name!, latitude: contact.latitude, longitude: contact.longitude, isShare: ShareStatus.kwaitingShared.rawValue, onCompletion: {_ in
                self.hideHUD()
                self.tableView.reloadData()
            })
        })
    }
    
    func shareLocation(contact: Contact) {
        self.showAlert(title: "Confirm", message: "Do you want share your location with this friend", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {
            self .showHUD()
            app_delegate.firebaseObject.shareLocation(toContact: contact, onCompletetionHandler: {
                DatabaseManager.updateContact(id: contact.id!, name: contact.name, latitude: contact.latitude, longitude: contact.longitude, isShare: ShareStatus.kShared.rawValue, onCompletion: {_ in
                    self.segmented.selectedSegmentIndex = kContactListIndex
                    self.currentIndex = kContactListIndex
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.contactArray.removeAll()
                        self.contactArray += DatabaseManager.getContactSharedLocation(contetxt: nil)
                        self.tableView.reloadData()
                        
                        self.hideHUD()
                    })
                })
            })
        })
    }
}
