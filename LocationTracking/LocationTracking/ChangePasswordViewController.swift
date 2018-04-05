//
//  ChangePasswordViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 11/29/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ChangePasswordViewController: OriginalViewController {

    @IBOutlet weak var oldPasswordTextfield: TextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var newPasswordTextField: TextField!
    @IBOutlet weak var confirmNewPasswordTextField: TextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField = TextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.setupUI()
        
        //Add tapGesture to View
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (changePasswordButton.frame.height + changePasswordButton.frame.origin.y) > screen_height {
            scrollView.isUserInteractionEnabled = true
            scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: changePasswordButton.frame.height + changePasswordButton.frame.origin.y + 20)
        }
    }
    
    //MARK: - Set up UI
    func setupUI() {
        oldPasswordTextfield.customBorder(radius: oldPasswordTextfield.frame.height/2, color: .clear)
        newPasswordTextField.customBorder(radius: newPasswordTextField.frame.height/2, color: .clear)
        confirmNewPasswordTextField.customBorder(radius: confirmNewPasswordTextField.frame.height/2, color: .clear)
        changePasswordButton.customBorder(radius: changePasswordButton.frame.height/2, color: .clear)
        
        oldPasswordTextfield.textRect(forBounds: oldPasswordTextfield.bounds)
        newPasswordTextField.textRect(forBounds: newPasswordTextField.bounds)
        confirmNewPasswordTextField.textRect(forBounds: confirmNewPasswordTextField.bounds)
    }
    
    func setupLanguage() {
        oldPasswordTextfield.placeholder = LocalizedString(key: "PLACE_HOLDER_OLD_PASSWORD")
        newPasswordTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_NEW_PASSWORD")
        confirmNewPasswordTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_CONFIRM_PASSWORD")

        changePasswordButton.setTitle(LocalizedString(key: "UPDATE"), for: .normal)
    }
    
    //MARK: - Keyboard
    override func keyboardEventWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: changePasswordButton.frame.height + changePasswordButton.frame.origin.y + 20 + keyboardSize.height)
        if (scrollView.frame.height - activeTextField.frame.origin.y - activeTextField.frame.height) < keyboardSize.height {
            scrollView.contentOffset = CGPoint.init(x: 0, y: keyboardSize.height - (scrollView.frame.height - activeTextField.frame.origin.y - activeTextField.frame.height))
        }
    }
    
    override func keyboardEventWillHide(_ notification: Notification) {
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: changePasswordButton.frame.height + changePasswordButton.frame.origin.y + 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action

    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedChangePassword(_ sender: UIButton) {
        
        if (oldPasswordTextfield.text?.count)! > 0 && (newPasswordTextField.text?.count)! > 0 && newPasswordTextField.text == confirmNewPasswordTextField.text {
            //Show loading
            self.showHUD()
            
            app_delegate.firebaseObject.changePassword(oldPassword: oldPasswordTextfield.text!, newPassword: newPasswordTextField.text!, onCompletionHandler: {error in
                //Hide loading
                self.hideHUD()
                
                if error != nil {
                    self.showAlert(title: "", message: (error?.localizedDescription)!, cancelTitle: "", okTitle: LocalizedString(key: "OK"), onOKAction: {_ in
                        self.view.makeToast((error?.localizedDescription)!, duration: 1.5, position: .center)
                    })
                } else {
                    //Update password at Userdefault
                    self.view.makeToast(LocalizedString(key: "TOAST_CHANGE_PASSWORD_SUCCESSFULLY"), duration: 1.5, position: .center)
                }
            })
        } else {
            self.showAlert(title: LocalizedString(key: "ALERT_ERROR_TITLE"), message: LocalizedString(key: "ALERT_AGAIN_INFO"), cancelTitle: LocalizedString(key: "CANCEL"), okTitle: LocalizedString(key: "OK"), onOKAction: {_ in
            })
        }
    }
    
    //Hide keyboard
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = textField as! TextField
    }
}
