//
//  GroupDetailViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 3/26/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GroupDetailViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    var interstitial: GADInterstitial!
    var group = GroupModel()
    var contactArray = [ContactModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up UI
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initAdsView()
        self.getContactModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Function
    func setupUI() {
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addTitleNavigation(title: group.name)
        self.addRightBarItem(imageName: "ic_add", title: "")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    func getContactModel() {
        app_delegate.firebaseObject.searchContactWithId(idArray: group.member, completionHandler: {array in
            self.contactArray.removeAll()
            self.contactArray += array
            
            self.tableView.reloadData()
        })
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        //Add contact to group
    }
    
    //MARK: - TableView Delegate, Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupDetailTableViewCell") as! GroupDetailTableViewCell
        cell.setupCell(contact: contactArray[indexPath.row])
        
        return cell
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
