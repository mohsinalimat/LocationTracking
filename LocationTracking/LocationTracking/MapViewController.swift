//
//  MapViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/8/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMobileAds

class MapViewController: OriginalViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADInterstitialDelegate, GADBannerViewDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 12.0
    var currentContact: Contact?
    var marker: GMSMarker?

    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ic_menu",title: "")
        self.addRightBarItem(imageName: "icon_add_user",title: "")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initMapView()
        self.getCurrentLocation()
        if currentContact == nil {
            self.addTitleNavigation(title: "Location Tracking")
        } else {
            self.addTitleNavigation(title: (currentContact?.email)!)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init View
    //Init MapView
    func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude:0,
                                              longitude:0,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - bannerView.frame.size.height), camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
    }
    
    //Init Location
    func getCurrentLocation() {
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude, zoom: zoomLevel)
            mapView.camera = camera
        locationManager.startUpdatingLocation()
    }
    
    
    //Init Banner View
    func initAdsView() {
        bannerView.adUnitID = kBannerAdUnitId;
        bannerView.rootViewController = self;
        bannerView.delegate = self
        bannerView.load(GADRequest())
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
    
    func updateMarker() {
        if (currentContact != nil) {
            mapView.clear()
            let position = CLLocationCoordinate2DMake((currentContact?.latitude)!,(currentContact?.longitude)!)
            marker = GMSMarker(position: position)
            marker?.title = currentContact?.email
            marker?.map = mapView
            let newCamera = GMSCameraPosition.camera(withLatitude: (currentContact?.latitude)!, longitude: (currentContact?.longitude)!, zoom: self.zoomLevel)
            mapView.camera = newCamera
        }
    }
    
// MARK: - GMSMapViewDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get current location
        currentLocation = locations.last!

        //Update location
        guard let profile = app_delegate.profile else {
            return
        }
        app_delegate.firebaseObject.updateLocation(id:profile.id!, lat: currentLocation.coordinate.latitude, long:currentLocation.coordinate.longitude )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    //MARK: - Banner Admob Delegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    //MARK: - Interstitial Delegate
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
        
        // [Admob] Init Interstal ads
//        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        //Show Menu friends list
        if let drawerController = self.parent?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        //Add new contact
        let addContactViewController = main_storyboard.instantiateViewController(withIdentifier: "AddContactViewController") as! AddContactViewController
        self.navigationController?.pushViewController(addContactViewController, animated: true)
    }
}
