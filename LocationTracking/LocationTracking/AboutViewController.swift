//
//  AboutViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 9/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tappedSendComment(_ sender: UIButton) {
        
    }
}
