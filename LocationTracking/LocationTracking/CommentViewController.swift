//
//  CommentViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 9/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class CommentViewController: OriginalViewController {

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSendComment(_ sender: UIButton) {
        if commentTextView.text.characters.count > 0 {
            app_delegate.firebaseObject.sendCommentAboutApp(comment: commentTextView.text, onCompletetionHandler: {_ in
                self.showAlert(title: "", message: "Thank you for your comment", cancelTitle: "OK", okTitle: "")
            })
        } else {
            self.showAlert(title: "", message: "Please input your comment", cancelTitle: "OK", okTitle: "")
        }

    }
}
