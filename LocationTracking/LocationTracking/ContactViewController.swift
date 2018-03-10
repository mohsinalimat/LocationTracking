//
//  ContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/15/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.

import UIKit

class ContactViewController : OriginalViewController,UITableViewDelegate,UITableViewDataSource,ContactTableViewCellDelegate {
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var locationArray = [LocationEntity]()
    var groupArray = [GroupEntity]()
    var contactArray = [Contact]()
    var currentIndex = kContactListIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initRightBarView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.refreshContactData()
        self.referentCurrentContact()
        
        self.navigationController!.view.layer.removeAllAnimations()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init Object
    func initView() {
        segmented.selectedSegmentIndex = currentIndex
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.tableHeaderView = UIView.init(frame: CGRect.zero)
        self.addLeftBarItem(imageName: "icon_close", title: "")
        self.initRightBarView()
    }
    
    func initRightBarView() {
        let rightBarView = UIView.init(frame: CGRect.init(x: 0, y: 2, width: 80, height: 35))
        
        //Init fresh Button
        let refreshButton = UIButton.init(type: UIButtonType.custom)
        refreshButton.isExclusiveTouch = true
        refreshButton.addTarget(self, action: #selector(tappedRefresh), for: UIControlEvents.touchUpInside)
        refreshButton.frame = CGRect.init(x: 0, y: 0, width: rightBarView.frame.size.height, height: rightBarView.frame.size.height)
        refreshButton.setImage(UIImage.init(named: "refresh"), for: UIControlState.normal)
        rightBarView.addSubview(refreshButton)
        
        //Init profile button
        let profileButton = UIButton.init(type: UIButtonType.custom)
        profileButton.isExclusiveTouch = true
        profileButton.addTarget(self, action: #selector(tappedEditProfile), for: UIControlEvents.touchUpInside)
        profileButton.frame = CGRect.init(x: 45, y: 0, width: refreshButton.frame.size.height, height: refreshButton.frame.size.height)
        profileButton.setImage(UIImage.init(named: "profile"), for: UIControlState.normal)
        rightBarView.addSubview(profileButton)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarView)
    }
    
    //MARK: - Data
    func refreshContactData() {
        switch segmented.selectedSegmentIndex {
        case kContactListIndex:
            contactArray.removeAll()
            contactArray = DatabaseManager.getContactRequestedLocation(contetxt: nil)
            print("contat count: " + String(contactArray.count))
            tableView.reloadData()
            break
        case kGroupListIndex:
            groupArray.removeAll()
            groupArray = DatabaseManager.getAllGroup(context: nil)
            tableView.reloadData()
            break
        case kLocationListIndex:
            locationArray.removeAll()
            locationArray = DatabaseManager.getAllLocationList(context: nil)
            tableView.reloadData()
            break
        default:
            contactArray.removeAll()
            contactArray = DatabaseManager.getRequestToMeContact(contetxt: nil)
            tableView.reloadData()
            break
        }
        self.hideHUD()
    }
    
    //Update when contact changed location
    func referentCurrentContact() {
        app_delegate.firebaseObject.referentToContact(onCompletionHandler: {_ in
            let visibleViewController: UIViewController = Common.getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)!
            if visibleViewController is ContactViewController {
                let contactVC = visibleViewController as! ContactViewController
                contactVC.refreshContactData()
            }
        })
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
            app_delegate.firebaseObject.shareOnFacebook()
    }
    
    @IBAction func tappedShareOnTwitter(_ sender: UIButton) {
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        //Init CATransition
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: true)
    }
    
    //Refresh contact from server
    func tappedRefresh() {
        self.showHUD()
        let profile = DatabaseManager.getProfile()
        app_delegate.firebaseObject.refreshData(email: (profile?.email)!, name: (profile?.name)!, completionHandler: {isSuccess in
            self.hideHUD()
            self.refreshContactData()
        })
    }
    
    func tappedEditProfile() {
        let profileViewController = main_storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    //Hide keyboard
    func hideKeyboard() {
        view.endEditing(true)
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
        self.tappedLeftBarButton(sender: UIButton())
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCellAtIndexPath(indexPath: indexPath)
        }
    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
    //MARK: - Marker
    func displayMarker(indexPath: IndexPath) {
        //Show Map View
        let mapViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! MapViewController
            
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
    
    //MARK: - ContactTableViewCell Delegate
    func requestLocation(contact: Contact) {
        self .showHUD()
        app_delegate.firebaseObject.requestLocation(toContact: contact, onCompletetionHandler: {
            DatabaseManager.updateContact(id: contact.id!, name: contact.name!, latitude: contact.latitude, longitude: contact.longitude, isShare: ShareStatus.kwaitingShared.rawValue, onCompletion: {_ in
                self.tableView.reloadData()
                self.hideHUD()
            })
        })
    }
    
    func shareLocation(contact: Contact) {
        self.showAlert(title: "Confirm", message: "Do you want share your location with this friend", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {
            self .showHUD()
            
            //Change selected index of segmented
            self.segmented.selectedSegmentIndex = kContactListIndex
            self.currentIndex = kContactListIndex
            let profile = DatabaseManager.getProfile()
            
            app_delegate.firebaseObject.shareLocation(toContact: contact, onCompletetionHandler: {
                app_delegate.firebaseObject.refreshData(email: (profile?.email)!, name: (profile?.name)!, completionHandler: {isSuccess in
                    self.hideHUD()
                    self.refreshContactData()
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
        self.showAlert(title: message, message: "", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            self.deleteObject(indexPath: indexPath)
        })
    }
    
    func deleteObject(indexPath: IndexPath) {
        self.showHUD()
        switch segmented.selectedSegmentIndex {
        case kGroupListIndex:
            let group = groupArray[indexPath.row]
            app_delegate.firebaseObject.deleteGroup(group: group, onCompletionHandler: {_ in
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
