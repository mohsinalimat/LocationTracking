//
//  SearchLocationViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 11/24/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SearchLocationViewController: OriginalViewController, UITableViewDelegate, UITableViewDataSource, SearchLocationDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var locationArray = [LocationModel]()
    var selectedLocationArray = [LocationModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Layout
    func initLayout() {
        self.addLeftBarItem(imageName: "ico_back",title: "")
        self.addRightBarItem(imageName: "save", title: "")
        self.addTitleNavigation(title: "Search Location")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        searchView.setupBorder()
    }
    
    //MARK: - Action
    @IBAction func tappedSearchLocation(_ sender: UIButton) {
        if (searchLocationTextField.text?.count)! == 0 {
            view.makeToast("Please input location name to search.", duration: 2.0, position: .center)
            return
        }
        
        if (searchLocationTextField.text?.count)! > 0 {
            self.showHUD()
            if (searchLocationTextField.text?.count)! > 0 {
                app_delegate.firebaseObject.searchLocation(searchString: searchLocationTextField.text!, onCompletionHandler: {(array) in
                    self.locationArray.removeAll()
                    
                    if array.count > 0 {
                        for locationModel in array as [LocationModel] {
                            if !(app_delegate.locationArray.contains(locationModel.id)) {
                                self.locationArray.append(locationModel)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.hideHUD()
                    }
                })
            }
        }
    }
    
    //Tapped to back
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        if selectedLocationArray.count > 0 {
            self.showHUD()
            
            //Add location to contact
            app_delegate.firebaseObject.addLocationToContact(id: app_delegate.profile.id, locationAray: selectedLocationArray)
        
            self.hideHUD()
            //Index of Map View Controller
            let index = (self.navigationController?.viewControllers.count)! - 2
            let mapViewController = self.navigationController?.viewControllers[index]
            let contactViewController = main_storyboard.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
            contactViewController.currentIndex = 3
            
            //Remove SearchLocationViewController
            self.navigationController?.viewControllers.removeLast()
            
            //Push to contactViewController from MapViewController
            mapViewController?.navigationController?.pushViewController(contactViewController, animated: true)
        } else {
            view.makeToast("Please choose a location from the list.", duration: 2.0, position: .center)
        }
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tappedSearchLocation(searchButton)
        return true
    }
    
    //MARK: - Cell Delegate
    func SaveLocation(indexPath: IndexPath) {
        selectedLocationArray.append(locationArray[indexPath.row])
    }
    
    //MARK: - UITableView Delegate,Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationTableViewCell") as! SearchLocationTableViewCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.setupCell(location: locationArray[indexPath.row])
        return cell
    }
}
