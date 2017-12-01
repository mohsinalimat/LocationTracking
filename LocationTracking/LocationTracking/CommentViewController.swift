//
//  CommentViewController.swift
//  LocationTracking
//
//  Created by Hai Dang Nguyen on 9/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class CommentViewController: OriginalViewController {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        //Add tapGesture to View
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        //Handle Keyboard when received notification
        self.handleKeyboard()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Set up UI
    func setupUI() {
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addTitleNavigation(title: "Comment")
        sendButton.customBorder(radius: 3,color: .clear)
        commentTextView.customBorder(radius: 4,color: .white)
    }
    //MARK: - Keyboard
    func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Show keyboard
    func keyboardWillAppear(notification: Notification){
        self.adjustKeyboardShow(open: true, notification: notification)
    }
    
    //Hide keyboard
    func keyboardWillDisappear(notification: Notification){
        self.adjustKeyboardShow(open: false, notification: notification)
    }
    
    func adjustKeyboardShow(open: Bool, notification: Notification){
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let height = (keyboardFrame.height + 20) * (open ? 1 : -1)
        scrollView.contentInset.bottom += height
        scrollView.scrollIndicatorInsets.bottom += height
    }
    
    //Hide keyboard
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - IBAction
    @IBAction func tappedSendComment(_ sender: UIButton) {
        if commentTextView.text.characters.count > 0 {
            app_delegate.firebaseObject.sendCommentAboutApp(comment: commentTextView.text, onCompletetionHandler: {_ in
                self.showAlert(title: "", message: "Thank you for your comment", cancelTitle: "", okTitle: "OK", onOKAction: {_ in
                    self.commentTextView.text = ""
                })
            })
        } else {
            self.showAlert(title: "", message: "Please input your comment", cancelTitle: "OK", okTitle: "", onOKAction: {_ in
            
            })
        }
    }

    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
