//
//  LanguageViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 4/3/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class LanguageViewController: OriginalViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    let languageArray = ["en", "ja"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Function
    func setupUI() {
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Delegate, DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        cell.languageLabel.text = LocalizedString(key: languageArray[indexPath.row])
        if languageArray[indexPath.row] == kUserDefault.object(forKey: kLanguageCode) as! String {
            cell.tickImageView.isHidden = false
        } else {
            cell.tickImageView.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kUserDefault.set(languageArray[indexPath.row], forKey: kLanguageCode)
        LocalizationSetLanguage(language: languageArray[indexPath.row])
        tableView.reloadData()
    }
}
