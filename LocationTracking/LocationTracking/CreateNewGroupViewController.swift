//
//  CreateNewGroupViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 10/16/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CreateNewGroupViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, createGroupDelegate, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var groupNameTextField: TextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var membersLabel: UILabel!
    var interstitial: GADInterstitial!
    var selectedContactArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupTableView()
        selectedContactArray.append(app_delegate.profile.id)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
        self.initAdsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //SetupUI
    func setupNavigationBar() {
        self.addLeftBarItem(imageName: "ico_back",title: "")
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: LocalizedString(key: "NEW_GROUP_TITLE"))
        groupNameTextField.textRect(forBounds: groupNameTextField.bounds)
        groupNameTextField.setupBorder()
    }
    
    func setupTableView() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        //Get contact list
        tableView.reloadData()
    }
    
    func setupLanguage() {
        groupNameTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_INPUT_GROUP_NAME")
        membersLabel.text = LocalizedString(key: "NEW_GROUP_MEMBER")
    }
    
    //MARK: - Action
    override func tappedRightBarButton(sender: UIButton) {
        if (groupNameTextField.text?.count)! > 0 {
            
            if selectedContactArray.count < 2 {
                view.makeToast(LocalizedString(key: "TOAST_ADD_CONTACT_TO_GROUP"), duration: 2.0, position: .center)
                return
            }
            self.showHUD()
            app_delegate.firebaseObject.createGroup(name: groupNameTextField.text!, array: selectedContactArray, onCompletionHandler: {
                self.hideHUD()
                self.navigationController?.viewControllers.removeLast()

                let contactViewController = main_storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
                contactViewController.currentIndex = kGroupListIndex

                let nav = UINavigationController.init(rootViewController: contactViewController)
                app_delegate.mapViewController.present(nav, animated: true, completion: nil)

            })
            
        } else {
            view.makeToast(LocalizedString(key: "TOAST_INPUT_GROUP_NAME"), duration: 2.0, position: .center)
        }
    }
    
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        return sharedContactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateNewGroupTableViewCell") as! CreateNewGroupTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        cell.setupCell(contact: sharedContactArray[indexPath.row])
        return cell
    }
    
    //MARK: - Cell Delegate
    func addToGroup(indexPath: IndexPath) {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        let contact: ContactModel = sharedContactArray[indexPath.row]
        selectedContactArray.append(contact.id)
    }
    
    func deleteFromGroup(indexPath: IndexPath) {
        let sharedContactArray = app_delegate.contactArray.filter{$0.isShare == 0}
        let contact: ContactModel = sharedContactArray[indexPath.row]
        selectedContactArray = selectedContactArray.filter{$0 != contact.id}
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
