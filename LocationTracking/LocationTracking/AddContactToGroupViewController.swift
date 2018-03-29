//
//  AddContactToGroupViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 3/29/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AddContactToGroupViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, SearchContactDelegate, GADInterstitialDelegate, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    var interstitial: GADInterstitial!
    var group = GroupModel()
    var contactArray = [ContactModel]()
    var selectContactArray = [ContactModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initAdsView()
        
        self.getContactModel()
    }
    
    //MARK: - Function
    func setupUI() {
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addTitleNavigation(title: group.name)
        self.addRightBarItem(imageName: "save", title: "")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func getContactModel() {
        for contact in app_delegate.contactArray {
            if !group.member.contains(contact.id) {
                contactArray.append(contact)
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        app_delegate.firebaseObject.addContactToGroup(groupId: group.id, contactArray: selectContactArray, onCompletionHandler: {_ in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    //MARK: - TableView Delegate, Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContactTableViewCell") as! SearchContactTableViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        cell.setupCell(contact: contactArray[indexPath.row])

        return cell
    }
    
    //MARK: - Cell Delegate
    func SaveContact(indexPath: IndexPath) {
        selectContactArray.append(contactArray[indexPath.row])
    }
    
    func unSelected(indexPath: IndexPath) {
        if selectContactArray.contains(contactArray[indexPath.row]) {
            selectContactArray = selectContactArray.filter{$0 != contactArray[indexPath.row]}
        }
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
