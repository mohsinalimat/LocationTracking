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
    
    var locationArray = [LocationEntity]()
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
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.tableHeaderView = UIView.init(frame: CGRect.zero)
        self.addLeftBarItem(imageName: "ic_logout", title: "")
        self.addRightBarItem(imageName: "refresh", title: "")
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
        case kLocationListIndex:
            locationArray.removeAll()
            locationArray += DatabaseManager.getAllLocationList(context: nil)
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
    
    @IBAction func tappedDelete(_ sender: UIButton) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmented.selectedSegmentIndex == kGroupListIndex {
            return groupArray.count
        }
        if segmented.selectedSegmentIndex == kLocationListIndex {
            return locationArray.count
        }
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        if segmented.selectedSegmentIndex == kLocationListIndex {
            cell.setupLocationCell(location: locationArray[indexPath.row])
        } else if segmented.selectedSegmentIndex == kGroupListIndex {
            cell.setupGroupCell(group: groupArray[indexPath.row], memberCount: groupArray.count)
        } else {
            cell.setupCell(contact: contactArray[indexPath.row])
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmented.selectedSegmentIndex == kContactListIndex || segmented.selectedSegmentIndex == kRequestShareIndex {
            //Tapped contact cell
            let selectedContact = contactArray[indexPath.row]
            if selectedContact.isShare != 0 {
                view.makeToast("Please wait for the user to share the location with you.", duration: 1.5, position: .center)
                return
            }
        }
        
        self.displayMarker(indexPath: indexPath)
    }
    
    //MARK: - Marker
    func displayMarker(indexPath: IndexPath) {
        //Show Map View
        if let drawerController = self.parent?.parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
            let mapNavigationViewController = drawerController.mainViewController as! UINavigationController
            let mapViewController = mapNavigationViewController.viewControllers.last as! MapViewController
            
            mapViewController.currentContactArray.removeAll()
            if segmented.selectedSegmentIndex == kGroupListIndex {
                //Tapped group cell

                let sharedContactArray = DatabaseManager.getContactSharedLocation(contetxt: nil)
                let group = groupArray[indexPath.row]
                
                for contact in sharedContactArray! {
                    if (group.member?.contains(contact.id!))! {
                        mapViewController.currentContactArray.append(contact)
                    }
                }
                //Add observer when changed contact
                mapViewController.updateMarker()

            } else if segmented.selectedSegmentIndex == kLocationListIndex {
                let location = locationArray[indexPath.row]
                //Add observer when changed contact
                mapViewController.reDrawMarkerWithPosition(latitude: location.latitude, longitude: location.longitude, name: location.name!)

            } else {
                mapViewController.currentContact = contactArray[indexPath.row]
                mapViewController.currentContactArray.append(contactArray[indexPath.row])
                //Add observer when changed contact
                mapViewController.updateMarker()
            }
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
                    
                    DispatchQueue.main.async {
                        self.contactArray.removeAll()
                        self.contactArray += DatabaseManager.getContactSharedLocation(contetxt: nil)
                        self.tableView.reloadData()
                        
                        self.hideHUD()
                    }
                })
            })
        })
    }
    
    //Delete cell
    func deleteCellAtIndexPath(indexPath: IndexPath) {
        var message = ""
        
        switch segmented.selectedSegmentIndex {
        case kGroupListIndex:
            let group = groupArray[indexPath.row]
            message = "Do you want to delete group: " + group.name!
            break
        case kLocationListIndex:
            let location = locationArray[indexPath.row]
            message = "Do you want to delete location: " + location.name!
            break
        default:
            let contact = contactArray[indexPath.row]
            message = "Do you want to delete contact: " + contact.name!
            break
        }
        self.showAlert(title: "", message: message, cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            self.deleteObject(indexPath: indexPath)
        })
    }
    
    func deleteObject(indexPath: IndexPath) {
        self.showHUD()
        switch segmented.selectedSegmentIndex {
        case kGroupListIndex:
            let group = groupArray[indexPath.row]
            app_delegate.firebaseObject.deleteGroup(groupId: group.id!, onCompletionHandler: {_ in
                self.refreshContactData()
                self.hideHUD()
            })
            break
        case kLocationListIndex:
            let location = locationArray[indexPath.row]
            app_delegate.firebaseObject.deleteLocation(locationId: location.id! ,onCompletionHandler: {_ in
                self.refreshContactData()
                self.hideHUD()
            })
            break
        default:
            let contact = contactArray[indexPath.row]
            app_delegate.firebaseObject.deleteContact(contactId: contact.id!, atUserId: (app_delegate.profile?.id)!, onCompletionHandler: {_ in
                self.refreshContactData()
                self.hideHUD()
            })

            break
        }
    }
}
