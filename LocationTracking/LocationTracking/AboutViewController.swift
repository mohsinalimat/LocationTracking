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
    @IBOutlet weak var aboutLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let about = UserDefaults.standard.object(forKey: "about")
        self.aboutLabel.text = about as! String?


    }

    override func viewWillAppear(_ animated: Bool) {
        app_delegate.firebaseObject.getAbout {
            let about = UserDefaults.standard.object(forKey: "about")
            self.aboutLabel.text = about as! String?
            self.scrollView.contentSize = CGSize.init(width: self.scrollView.contentSize.width, height: self.aboutLabel.frame.size.height + 20)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBAction
    @IBAction func tappedSendComment(_ sender: UIButton) {
        
    }
    
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
