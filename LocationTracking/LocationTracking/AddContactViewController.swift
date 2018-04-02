//
//  AddContactViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/20/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AddContactViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, SearchContactDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial!

    var contactArray = [ContactModel]()
    var selectedContactArray = [ContactModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
        self.initAdsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Layout
    func initLayout() {
        self.addLeftBarItem(imageName: "ico_back",title: "")
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: "Search contacts")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        searchView.setupBorder()
    }
    
    func setupLanguage() {
        searchTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_SEARCH_CONTACT_NAME")
    }
    
    //MARK: - Action
    @IBAction func tappedSearchContact(_ sender: UIButton) {
        if (searchTextField.text?.count)! > 0 {
            self.showHUD()
            app_delegate.firebaseObject.searchContactWithName(name: searchTextField.text!, completionHandler: {(array) in
                
                self.contactArray.removeAll()
                self.contactArray += array as [ContactModel]

                //Remove me from contact list
                self.contactArray = self.contactArray.filter{$0.id != app_delegate.profile.id}
                
                //Remove contacts who I added to my contact array
                for contact in app_delegate.contactArray {
                    self.contactArray = self.contactArray.filter{$0.id != contact.id}
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.hideHUD()
                }
            })
        }
    }
    
    //Save contact into Favorite
    override func tappedRightBarButton(sender: UIButton) {
        if selectedContactArray.count > 0 {
            app_delegate.firebaseObject.requestToShareLocation(selectContactArray: selectedContactArray)
            self.navigationController?.viewControllers.removeLast()

            let contactViewController = main_storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
            contactViewController.currentIndex = kSharedContactIndex
            
            let nav = UINavigationController.init(rootViewController: contactViewController)
            app_delegate.mapViewController.present(nav, animated: true, completion: nil)

        } else {
            view.makeToast(LocalizedString(key: "TOAST_SELECT_CONTACT_FROM_LIST"), duration: 2.0, position: .center)
        }
    }
    
    //Tapped to back
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContactTableViewCell") as! SearchContactTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setupCell(contact: contactArray[indexPath.row])
        
        let currentContact = contactArray[indexPath.row]
        if selectedContactArray.contains(currentContact) {
            cell.selectionButton.isSelected = true
        } else {
            cell.selectionButton.isSelected = false
        }
        
        return cell
    }
    
    //MARK: - Cell Delegate
    func SaveContact(indexPath: IndexPath) {
        selectedContactArray.append(contactArray[indexPath.row])
    }
    
    func unSelected(indexPath: IndexPath) {
        if selectedContactArray.contains(contactArray[indexPath.row]) {
            selectedContactArray = selectedContactArray.filter{$0 != contactArray[indexPath.row]}
        }
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tappedSearchContact(searchButton)
        return true
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
