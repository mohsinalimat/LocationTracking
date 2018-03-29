//
//  GroupDetailViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 3/26/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GroupDetailViewController: OriginalViewController, GADInterstitialDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initAdsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
