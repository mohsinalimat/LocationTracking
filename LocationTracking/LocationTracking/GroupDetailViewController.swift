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
    @IBOutlet weak var editGroupNameView: UIView!
    @IBOutlet weak var editGroupNameButton: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var backgroundTextFieldView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initAdsView()
        group = app_delegate.groupArray.filter({$0.id == group.id}).first!
        self.getContactModel()
        
        //set up UI
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        editGroupNameView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Function
    func setupUI() {
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addRightBarItem(imageName: "ic_add", title: "")
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
        //Set up title
        let titleButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 40))
        titleButton.tintColor = .white
        titleButton.setTitle(group.name, for: .normal)
        titleButton.addTarget(self, action: #selector(tappedShowEditGroupNameView), for: .touchUpInside)
        
        self.navigationItem.titleView = titleButton
        
        //Custom layer
        editGroupNameView.customBorder(radius: 4.0, color: .clear)
        editGroupNameButton.customBorder(radius: editGroupNameButton.frame.height/2, color: .clear)
        editGroupNameButton.setTitle(LocalizedString(key: "OK"), for: .normal)
        backgroundTextFieldView.customBorder(radius: groupNameTextField.frame.height/2, color: .white)
        groupNameTextField.textAlignment = .center
        groupNameTextField.text = group.name
    }
    
    func getContactModel() {
        app_delegate.firebaseObject.searchContactWithId(idArray: group.member, completionHandler: {array in
            self.contactArray.removeAll()
            self.contactArray += array
            
            self.contactArray = self.contactArray.filter{$0.id != app_delegate.profile.id}
            self.tableView.reloadData()
        })
    }
    
    @objc func tappedShowEditGroupNameView() {
        editGroupNameView.isHidden = false
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        //Add contact to group
        let addcontactViewController = main_storyboard.instantiateViewController(withIdentifier: "AddContactToGroupViewController") as! AddContactToGroupViewController
        addcontactViewController.group = group
        self.navigationController?.pushViewController(addcontactViewController, animated: true)
    }
    
    @IBAction func tappedEditGroupName(_ sender: UIButton) {
        editGroupNameView.isHidden = true
        if groupNameTextField.text!.count > 0 {
            self.showHUD()
            app_delegate.firebaseObject.updateGroupName(newGroupName: groupNameTextField.text!, groupId: group.id)
            let titleButton = self.navigationItem.titleView as! UIButton
            titleButton.setTitle(groupNameTextField.text!, for: .normal)
            self.hideHUD()
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if app_delegate.profile.id == group.owner {
                self.showAlert(title: LocalizedString(key: "ALERT_CONFIRM_TITLE"), message: LocalizedString(key: "ALERT_CONFIRM_DELETE_MEMBER"), cancelTitle: LocalizedString(key: "CAnCEL"), okTitle: LocalizedString(key: "OK"), onOKAction: {_ in
                    self.showHUD()
                    let contact = self.contactArray[indexPath.row]
                    app_delegate.firebaseObject.deleteContactFromGroup(contact: contact, group: self.group)
                    app_delegate.firebaseObject.updateGroup(groupId: self.group.id, onCompletionHandler: {newGroup in
                        //Update group
                        self.group = newGroup
                        app_delegate.groupArray.filter({$0.id == self.group.id}).first?.member = newGroup.member

                        //Remove contact
                        self.contactArray = self.contactArray.filter{$0.id != contact.id}
                        self.tableView.reloadData()
                        
                        self.hideHUD()
                    })
                })
            } else {
                view.makeToast(LocalizedString(key: "TOAST_ONLY_OWNER_REMOVE_MEMBER"), duration: 2.0, position: .center)
            }
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
