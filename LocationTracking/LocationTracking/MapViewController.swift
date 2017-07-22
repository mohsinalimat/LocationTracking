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

class MapViewController: OriginalViewController,GMSMapViewDelegate,CLLocationManagerDelegate {

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
        self.addTitleNavigation(title: "Location Tracking")
        self.addRightBarItem(imageName: "icon_add_user",title: "")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initMapView()
        self.getCurrentLocation()
        if currentContact != nil {
            self.referentCurrentContact(contactId: (currentContact?.id)!)
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
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
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
    
    func referentCurrentContact(contactId:String) {
        if currentContact != nil {
            app_delegate.firebaseObject.referentToContact(contactId: contactId, onCompletionHandler: {_ in
                self.currentContact = DatabaseManager.getContact(id: contactId,contetxt: nil)
                self.updateMarker()
            })
            self.updateMarker()
        }
    }
    
    func updateMarker() {
        mapView.clear()
        let position = CLLocationCoordinate2DMake((currentContact?.latitude)!,(currentContact?.longitude)!)
        marker = GMSMarker(position: position)
        marker?.title = currentContact?.email
        marker?.map = mapView
        let newCamera = GMSCameraPosition.camera(withLatitude: (currentContact?.latitude)!, longitude: (currentContact?.longitude)!, zoom: self.zoomLevel)
        mapView.camera = newCamera
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
