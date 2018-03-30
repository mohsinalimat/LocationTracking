//
//  ContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/15/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.

import UIKit
import GoogleMobileAds

class ContactViewController : OriginalViewController, UITableViewDelegate, UITableViewDataSource, ContactTableViewCellDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var currentIndex = kSharedContactIndex

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.addObserveNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initAdsView()
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
        tableView.reloadData()
    }
    
    //MARK: - Init Object
    func initView() {
        segmented.selectedSegmentIndex = currentIndex
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.tableHeaderView = UIView.init(frame: CGRect.zero)
        self.addLeftBarItem(imageName: "icon_close", title: "")
        self.addTitleNavigation(title: "Contacts")
    }
    
    //MARK: - Action
    @IBAction func tappedChangeSegmentedIndex(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
            let requestArray = app_delegate.contactArray.filter{$0.isShare == kRequestedToMe}

            return requestArray.count
        }
        let sharedArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}

        return sharedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.indexPath = indexPath
        
        if segmented.selectedSegmentIndex == kLocationListIndex {
            if app_delegate.locationArray.count > indexPath.row {
                cell.setupLocationCell(location: app_delegate.locationArray[indexPath.row])
            }
            
        } else if segmented.selectedSegmentIndex == kGroupListIndex {
            
            if app_delegate.groupArray.count > indexPath.row {
                cell.setupGroupCell(group: app_delegate.groupArray[indexPath.row], memberCount: app_delegate.groupArray.count)
            }
            
        } else if segmented.selectedSegmentIndex == kRequestShareIndex {
            
            let requestArray = app_delegate.contactArray.filter{$0.isShare == kRequestedToMe}
            if requestArray.count > indexPath.row {
                cell.setupCell(contact: requestArray[indexPath.row])
            }
            
        } else {
            let sharedArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}
            if sharedArray.count > indexPath.row {
                cell.setupCell(contact: sharedArray[indexPath.row])
            }
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmented.selectedSegmentIndex == kSharedContactIndex {
            //Tapped contact cell
            let sharedArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}

            let selectedContact = sharedArray[indexPath.row]
            if selectedContact.isShare != 0 {
                view.makeToast("Please wait for the user to share the location with you.", duration: 1.5, position: .center)
                return
            }
        }
        
        if segmented.selectedSegmentIndex == kRequestShareIndex {
            return
        }
        
        self.displayMarker(indexPath: indexPath)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCellAtIndexPath(indexPath: indexPath)
        }
    }
    
    //MARK: - Marker
    func displayMarker(indexPath: IndexPath) {
        //Show Map View
            app_delegate.mapViewController.currentContactArray.removeAll()
            if segmented.selectedSegmentIndex == kGroupListIndex {
                //Tapped group cell

                let sharedContactArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}
                let group = app_delegate.groupArray[indexPath.row]
                
                for contact in sharedContactArray {
                    if group.member.contains(contact.id) {
                        app_delegate.mapViewController.currentContactArray.append(contact)
                    }
                }
                //Add observer when changed contact
                app_delegate.mapViewController.group = group
                app_delegate.mapViewController.updateMarker()

            } else if segmented.selectedSegmentIndex == kLocationListIndex {
                let location = app_delegate.locationArray[indexPath.row]
                //Add observer when changed contact
                app_delegate.mapViewController.reDrawMarkerWithPosition(latitude: location.latitude, longitude: location.longitude, name: location.name)

            } else {
                let sharedContactArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}

                app_delegate.mapViewController.currentContactArray.append(sharedContactArray[indexPath.row])
                //Add observer when changed contact
                app_delegate.mapViewController.updateMarker()
            }
    }
    
    //MARK: - ContactTableViewCell Delegate
    func shareLocation(contact: ContactModel) {
        self.showAlert(title: "Confirm", message: "Do you want share your location with this friend", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {
            self .showHUD()

            app_delegate.firebaseObject.shareLocation(toContact: contact, onCompletetionHandler: {
                self.hideHUD()
            })
        })
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
        case kRequestedToMe:
            let requestArray = app_delegate.contactArray.filter{$0.isShare == kRequestedToMe}

            let contact = requestArray[indexPath.row]
            app_delegate.firebaseObject.deleteContact(contactId: contact.id, atUserId: app_delegate.profile.id, onCompletionHandler: {_ in
                self.hideHUD()
            })
            break
        default:
            let sharedArray = app_delegate.contactArray.filter{$0.isShare != kRequestedToMe}

            let contact = sharedArray[indexPath.row]
            app_delegate.firebaseObject.deleteContact(contactId: contact.id, atUserId: app_delegate.profile.id, onCompletionHandler: {_ in
                self.hideHUD()
            })
            break
        }
    }
    
    func showGroupInformation(group: GroupModel) {
        let groupDetailViewController = main_storyboard.instantiateViewController(withIdentifier: "GroupDetailViewController") as! GroupDetailViewController
        groupDetailViewController.group = group
        self.navigationController?.pushViewController(groupDetailViewController, animated: true)
    }
    
    //Init Banner View
    func initAdsView() {
        bannerView.adUnitID = kBannerAdUnitId;
        bannerView.rootViewController = self;
        bannerView.delegate = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        self.interstitial = createAndLoadInterstitial()
    }
    
    // MARK: - Init Interstitial
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: kInterstitialAdUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return GADInterstitial() //interstitial
    }
    
    func showInterstitialAds() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("[Admob] Ad wasn't ready!")
        }
    }
}
