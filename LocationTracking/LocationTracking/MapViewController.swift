//
//  MapViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/8/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import AVFoundation 
import GoogleMaps
import GooglePlaces
import GoogleMobileAds

class MapViewController: OriginalViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GADInterstitialDelegate, GADBannerViewDelegate {

    @IBOutlet weak var addNewLocationNameTextField: TextField!
    @IBOutlet weak var allowUpdateLocationSwitch: UISwitch!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var saveNewLocationButton: UIButton!
    @IBOutlet weak var closeAddNewLocationButton: UIButton!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var addNewLocationView: UIView!
    @IBOutlet weak var normalTypeButton: UIButton!
    @IBOutlet weak var hybridTypeButton: UIButton!
    @IBOutlet weak var newLongitudeLabel: UILabel!
    @IBOutlet weak var newLatitudeLabel: UILabel!
    
    var interstitial: GADInterstitial!
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 12.0
    var currentContactArray = [ContactModel]()
    var marker: GMSMarker?
    var isAddLocation: Bool?
    var isAllowUpdateLocation: Bool?
    var newLocation: CLLocationCoordinate2D?
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isAllowUpdateLocation = true
        self.addLeftBarItem(imageName: "ic_menu",title: "")
        self.addRightBarItem(imageName: "ic_add",title: "")
        self.initMapView()
        //Init Ads
        self.initAdsView()
        self.setupLayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        
        self.getCurrentLocation()
        self.addTitleNavigation(title: "Location Tracking")

        //Real time contact location
        self.referentCurrentContact()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        menuView.isHidden = true
        view.endEditing(true)
    }
    
    func updateLocationAddress(address: String) {
        let titleLabel = self.navigationItem.titleView as! UILabel
        titleLabel.text = address
        titleLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init View
    
    func setupLayer() {
        addContactButton.isExclusiveTouch = true
        addLocationButton.isExclusiveTouch = true
        addGroupButton.isExclusiveTouch = true
        saveNewLocationButton.isExclusiveTouch = true
        closeAddNewLocationButton.isExclusiveTouch = true
        
        addContactButton.customBorder(radius: addContactButton.frame.height/2, color: .white)
        addGroupButton.customBorder(radius: addGroupButton.frame.height/2, color: .white)
        addLocationButton.customBorder(radius: addLocationButton.frame.height/2, color: .white)
        normalTypeButton.customBorder(radius: normalTypeButton.frame.height/2, color: .clear)
        hybridTypeButton.customBorder(radius: hybridTypeButton.frame.height/2, color: .clear)
        addNewLocationNameTextField.customBorder(radius: addNewLocationNameTextField.frame.height/2, color: .lightGray)
        addNewLocationNameTextField.textRect(forBounds: addNewLocationNameTextField.bounds)
    }
    
    func hideAllCustomView() {
        menuView.isHidden = true
        addNewLocationView.isHidden = true
    }
    
    //Init MapView
    func initMapView() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                } else {
                    return
                    // User Rejected
                }
            })
        }
        let camera = GMSCameraPosition.camera(withLatitude:0.0,
                                              longitude:0.0,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - bannerView.frame.size.height), camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        
        //Bring button to front
        view.bringSubview(toFront: allowUpdateLocationSwitch)
        view.bringSubview(toFront: normalTypeButton)
        view.bringSubview(toFront: hybridTypeButton)
        view.bringSubview(toFront: searchLocationButton)
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
        
        let latitude  = locationManager.location != nil ? locationManager.location!.coordinate.latitude : 0
        let longitude = locationManager.location != nil ? locationManager.location!.coordinate.longitude : 0

        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
        mapView.camera = camera
        if allowUpdateLocationSwitch.isOn {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
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
    
    // MARK: - Update Location
    //Update when contact changed location
    func referentCurrentContact() {
//        app_delegate.firebaseObject.referentToContact(onCompletionHandler: {_ in
//            let visibleViewController: UIViewController = Common.getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)!
//            if visibleViewController is MapViewController {
//                let mapVC = visibleViewController as! MapViewController
//                mapVC.updateMarker()
//            }
//        })
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
        mapView.clear()
        for contact in currentContactArray {
            let position = CLLocationCoordinate2DMake(contact.latitude,contact.longitude)
            let marker = GMSMarker(position: position)
            marker.title = contact.name
            marker.icon = UIImage.init(named: "requestLocation")
            marker.map = mapView
            if currentContactArray.count == 1 {
                let newCamera = GMSCameraPosition.camera(withLatitude: contact.latitude, longitude: contact.longitude, zoom: self.mapView.camera.zoom)
                mapView.camera = newCamera
                Common.convertToAddress(latitude: contact.latitude, longitude: contact.longitude, onCompletionHandler: {address in
                    self.updateLocationAddress(address: address)
                })
            }
        }
    }
    
    func reDrawMarkerWithPosition(latitude: Double, longitude: Double, name: String) {
        mapView.clear()

        let position = CLLocationCoordinate2DMake(latitude,longitude)
        let marker = GMSMarker(position: position)
        marker.icon = UIImage.init(named: "requestLocation")
        marker.title = name
        marker.map = mapView
        let newCamera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.mapView.camera.zoom)
        mapView.camera = newCamera
        self.updateLocationAddress(address: name)
    }
    
// MARK: - GMSMapViewDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isAllowUpdateLocation! {
            return
        } else {
            isAllowUpdateLocation = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                //Get current location
                let lastLocation = locations.last!
                if self.currentLocation.coordinate.latitude != lastLocation.coordinate.latitude || self.currentLocation.coordinate.longitude != lastLocation.coordinate.longitude {
                    //Update current location
                    self.currentLocation = locations.last!
                    
                    //Update location
                    app_delegate.firebaseObject.updateLocation(id:app_delegate.profile.id, lat: self.currentLocation.coordinate.latitude, long:self.currentLocation.coordinate.longitude)
                }
                
                //Allow send location to server
                self.isAllowUpdateLocation = true
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        menuView.isHidden = true
        view.endEditing(true)
        if !addNewLocationView.isHidden {
            newLocation = coordinate
            //Adding new location
            self.setupNewLocation(newLocation: newLocation!)
        }
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
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
//        self.navigationItem.leftBarButtonItem?.isEnabled = false
//
//        let contactViewController = main_storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
//
//        //Init CATransition
//        let transition:CATransition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft
//        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
//        self.navigationController?.pushViewController(contactViewController, animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        //Show menu
        menuView.isHidden = !menuView.isHidden
        view.bringSubview(toFront: menuView)
    }
    
    @IBAction func tappedAllowUpdateLocation(_ sender: UISwitch) {
        if sender.isOn {
            locationManager.startUpdatingLocation()
            view.makeToast("Shared your location to friends", duration: 2, position: .center)
        } else {
            locationManager.stopUpdatingLocation()
            view.makeToast("Stoped sharing your location to friends", duration: 2, position: .center)
        }
    }
    
    @IBAction func tappedAddNewContact(_ sender: UIButton) {
        //Add new contact
//        self.navigationItem.leftBarButtonItem?.isEnabled = false
//        let addContactViewController = main_storyboard.instantiateViewController(withIdentifier: "AddContactViewController") as! AddContactViewController
//        self.navigationController?.pushViewController(addContactViewController, animated: true)
    }
    
    @IBAction func tappedAddNewgroup(_ sender: UIButton) {
        //Add new contact
//        self.navigationItem.leftBarButtonItem?.isEnabled = false
//        let addGroupViewController = main_storyboard.instantiateViewController(withIdentifier: "CreateNewGroupViewController") as! CreateNewGroupViewController
//        self.navigationController?.pushViewController(addGroupViewController, animated: true)
    }
    
    @IBAction func tappedAddNewLocation(_ sender: UIButton) {
        //Hide menu view
//        menuView.isHidden = true
//        
//        //Show action sheet
        self.showActionSheet(titleArray: ["Add new location","Search to add new location"], onTapped: {title in
            if title == "Add new location" {
                //Show view to add new location
                self.addNewLocationView.isHidden = false
                self.menuView.isHidden = true
                self.view.bringSubview(toFront: self.addNewLocationView)
                
                //Show my location
                self.newLocation = CLLocationCoordinate2DMake(app_delegate.profile.latitude, app_delegate.profile.longitude)
                self.setupNewLocation(newLocation: self.newLocation!)
                
            } else if title == "Search to add new location" {
                //Go to search location screen
                let searchLocationViewController = main_storyboard.instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
                self.navigationController?.pushViewController(searchLocationViewController, animated: true)
            }
        })

    }
    
    @IBAction func tappedSaveNewLocation(_ sender: UIButton) {
        if (newLocation == nil || (addNewLocationNameTextField.text?.count)! == 0) {
            view.makeToast("Please input location name.", duration: 2.0, position: .center)
            return
        }
        app_delegate.firebaseObject.createNewLocation(latitude: (newLocation?.latitude)!, longitude: (newLocation?.longitude)!, name: addNewLocationNameTextField.text!)
        view.makeToast("Saved new location successfully.", duration: 2.0, position: .center)
        addNewLocationView.isHidden = true
    }
    
    @IBAction func tappedCloseAddingNewLocation(_ sender: UIButton) {
        addNewLocationView.isHidden = true
    }
    
    @IBAction func tappedNormalMapType(_ sender: UIButton) {
        mapView.mapType = .normal
    }
    
    @IBAction func tappedHybridMapType(_ sender: UIButton) {
        mapView.mapType = .hybrid
    }
    
    func setupNewLocation(newLocation: CLLocationCoordinate2D) {
        newLatitudeLabel.text = String(format: "Lat: %.10f", newLocation.latitude)
        newLongitudeLabel.text = String(format: "Long: %.10f", newLocation.longitude)
    }
}
