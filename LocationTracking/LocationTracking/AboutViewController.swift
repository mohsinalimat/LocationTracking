//
//  AboutViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 9/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class AboutViewController: OriginalViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentButton.customBorder(radius: 3,color: .clear)
        initView()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        //Get about from server and display it after finished
        app_delegate.firebaseObject.getAbout {
            let about = UserDefaults.standard.object(forKey: "about")
            self.aboutLabel.text = about as! String?
            self.scrollView.contentSize = CGSize.init(width: self.scrollView.contentSize.width, height: self.aboutLabel.frame.size.height + self.commentButton.frame.height + 20)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        commentButton.customBorder(radius: commentButton.frame.height/2, color: Common.mainColor())
    }
    
    func initView() {
        //Init navigation bar
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addTitleNavigation(title: "About")
        
        //Display about from USerDefault
        let about = UserDefaults.standard.object(forKey: "about")
        self.aboutLabel.text = about as! String?
        self.scrollView.contentSize = CGSize.init(width: self.scrollView.contentSize.width, height: self.aboutLabel.frame.size.height + commentButton.frame.height + 20)
    }
    
    //MARK: - IBAction
    @IBAction func tappedSendComment(_ sender: UIButton) {
        let commentViewController = main_storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        self.present(commentViewController, animated: true, completion: nil)
    }
    
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
