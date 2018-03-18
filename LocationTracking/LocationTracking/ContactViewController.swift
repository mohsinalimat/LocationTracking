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
    
    var currentIndex = kSharedContactIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.addObserveNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.view.layer.removeAllAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Observe notification
    func addObserveNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSharedContact), name: Notification.Name("ChangedContact"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadGroup), name: Notification.Name("ChangedGroup"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadLocation), name: Notification.Name("ChangedLocation"), object: nil)
    }
    
    func reloadLocation() {
        if segmented.selectedSegmentIndex == kLocationListIndex {
            tableView.reloadData()
        }
    }
    
    func reloadGroup() {
        if segmented.selectedSegmentIndex == kGroupListIndex {
            tableView.reloadData()
        }
    }
    
    func reloadSharedContact() {
        if segmented.selectedSegmentIndex == kSharedContactIndex {
            tableView.reloadData()
        }
    }
    //MARK: - Init Object
    func initView() {
        segmented.selectedSegmentIndex = currentIndex
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.tableHeaderView = UIView.init(frame: CGRect.zero)
        self.addLeftBarItem(imageName: "icon_close", title: "")
        self.addRightBarItem(imageName: "profile", title: "")
    }
    
    //MARK: - Action
    @IBAction func tappedChangeSegmentedIndex(_ sender: UISegmentedControl) {
        tableView.reloadData()
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
    
    override func tappedRightBarButton(sender: UIButton) {
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
            return app_delegate.groupArray.count
        }
        if segmented.selectedSegmentIndex == kLocationListIndex {
            return app_delegate.locationArray.count
        }
        if segmented.selectedSegmentIndex == kRequestShareIndex {
            let requestArray = app_delegate.contactArray.filter{$0.isShare != 0}
            
            return requestArray.count
        }
        let sharedArray = app_delegate.contactArray.filter{$0.isShare == 0}
        
        return sharedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        if segmented.selectedSegmentIndex == kLocationListIndex {
            
            cell.setupLocationCell(location: app_delegate.locationArray[indexPath.row])
            
        } else if segmented.selectedSegmentIndex == kGroupListIndex {
            
            cell.setupGroupCell(group: app_delegate.groupArray[indexPath.row], memberCount: app_delegate.groupArray.count)
            
        } else if segmented.selectedSegmentIndex == kRequestShareIndex {
            
            let requestArray = app_delegate.contactArray.filter{$0.isShare != 0}
            cell.setupCell(contact: requestArray[indexPath.row])
            
        } else {
            
            let sharedArray = app_delegate.contactArray.filter{$0.isShare == 0}
            cell.setupCell(contact: sharedArray[indexPath.row])
            
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if segmented.selectedSegmentIndex == kSharedContactIndex || segmented.selectedSegmentIndex == kRequestShareIndex {
//            //Tapped contact cell
//            let selectedContact = app_delegate.contactArray[indexPath.row]
//            if selectedContact != 0 {
//                view.makeToast("Please wait for the user to share the location with you.", duration: 1.5, position: .center)
//                return
//            }
//        }
//
//        self.displayMarker(indexPath: indexPath)
//        self.tappedLeftBarButton(sender: UIButton())
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
//        let mapViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! MapViewController
//            
//            mapViewController.currentContactArray.removeAll()
//            if segmented.selectedSegmentIndex == kGroupListIndex {
//                //Tapped group cell
//
//                let sharedContactArray = DatabaseManager.getContactSharedLocation(contetxt: nil)
//                let group = groupArray[indexPath.row]
//                
//                for contact in sharedContactArray! {
//                    if (group.member?.contains(contact.id!))! {
//                        mapViewController.currentContactArray.append(contact)
//                    }
//                }
//                //Add observer when changed contact
//                mapViewController.updateMarker()
//
//            } else if segmented.selectedSegmentIndex == kLocationListIndex {
//                let location = locationArray[indexPath.row]
//                //Add observer when changed contact
//                mapViewController.reDrawMarkerWithPosition(latitude: location.latitude, longitude: location.longitude, name: location.name!)
//
//            } else {
//                mapViewController.currentContact = contactArray[indexPath.row]
//                mapViewController.currentContactArray.append(contactArray[indexPath.row])
//                //Add observer when changed contact
//                mapViewController.updateMarker()
//            }
    }
    
    //MARK: - ContactTableViewCell Delegate
    func requestLocation(contact: ContactModel) {
//        self .showHUD()
//        app_delegate.firebaseObject.requestLocation(toContact: contact, onCompletetionHandler: {
//            self.tableView.reloadData()
//            self.hideHUD()
//        })
    }
    
    func shareLocation(contact: ContactModel) {
//        self.showAlert(title: "Confirm", message: "Do you want share your location with this friend", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {
//            self .showHUD()
//
//            //Change selected index of segmented
//            self.segmented.selectedSegmentIndex = kSharedContactIndex
//            self.currentIndex = kSharedContactIndex
//            let profile = DatabaseManager.getProfile()
//
//            app_delegate.firebaseObject.shareLocation(toContact: contact, onCompletetionHandler: {
//                app_delegate.firebaseObject.refreshData(email: (profile?.email)!, name: (profile?.name)!, completionHandler: {isSuccess in
//                    self.hideHUD()
//                    self.refreshContactData()
//                })
//            })
//        })
    }
    
    //Delete cell
    func deleteCellAtIndexPath(indexPath: IndexPath) {
        var message = ""

        switch segmented.selectedSegmentIndex {
        case kGroupListIndex:
            let group = app_delegate.groupArray[indexPath.row]
            message = "Do you want to delete group: " + group.name
            break
        case kLocationListIndex:
            let location = app_delegate.locationArray[indexPath.row]
            message = "Do you want to delete location: " + location.name
            break
        default:
//            let contact = contactArray[indexPath.row]
            message = "Do you want to delete contact: " //+ contact.name!
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
            let group = app_delegate.groupArray[indexPath.row]
            app_delegate.firebaseObject.deleteGroup(group: group)
            hideHUD()
            break
        case kLocationListIndex:
            let location = app_delegate.locationArray[indexPath.row]
            app_delegate.firebaseObject.deleteLocation(locationId: location.id)
            hideHUD()
            break
        default:
//            let contact = contactArray[indexPath.row]
//            app_delegate.firebaseObject.deleteContact(contactId: contact.id!, atUserId: (app_delegate.profile?.id)!, onCompletionHandler: {_ in
//                self.hideHUD()
//            })
            break
        }
    }
}
