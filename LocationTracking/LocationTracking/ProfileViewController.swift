//
//  ProfileViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 9/30/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ProfileViewController: OriginalViewController {
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeTextField = TextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
        
        //Add tapGesture to View
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
        self.initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Set up UI
    func setupUI() {
        saveButton.customBorder(radius: saveButton.frame.height/2, color: Common.mainColor())
        changePasswordButton.customBorder(radius: changePasswordButton.frame.height/2, color: Common.mainColor())
        nameTextField.customBorder(radius: nameTextField.frame.height/2, color: .clear)
        emailTextField.customBorder(radius: emailTextField.frame.height/2, color: .clear)
        
        nameTextField.textRect(forBounds: nameTextField.bounds)
        emailTextField.textRect(forBounds: emailTextField.bounds)
    }
    
    func setupLanguage() {
        nameTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_NAME")
        emailTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_EMAIL")
        
        saveButton.setTitle(LocalizedString(key: "SAVE"), for: .normal)
        changePasswordButton.setTitle(LocalizedString(key: "CHANGE_PASSWORD"), for: .normal)
        signOutButton.setTitle(LocalizedString(key: "SIGN_OUT"), for: .normal)
    }
    
    //MARK: - Keyboard
    override func keyboardEventWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: scrollView.frame.height + keyboardSize.height)
        if (scrollView.frame.height - activeTextField.frame.origin.y - activeTextField.frame.height) < keyboardSize.height {
            scrollView.contentOffset = CGPoint.init(x: 0, y: keyboardSize.height - (scrollView.frame.height - activeTextField.frame.origin.y - activeTextField.frame.height))
        }
    }
    
    override func keyboardEventWillHide(_ notification: Notification) {
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: scrollView.frame.height)
    }
    
    //MARK: - Init Data
    func initData() {
        nameTextField.text = app_delegate.profile.name
        emailTextField.text = app_delegate.profile.email
    }
    
    //MARK: Action
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedSave(_ sender: UIButton) {
        if (nameTextField.text?.count)! > 0 && (emailTextField.text?.count)! > 0 {
            self.showHUD()
            self.updateProfile {
                self.view.makeToast(LocalizedString(key: "TOAST_SUCCESSFULLY"), duration: 2.0, position: .center)
                self.hideHUD()
            }
        } else {
            view.makeToast(LocalizedString(key: "TOAST_USER_NAME_EMPTY"), duration: 2.0, position: .center)
        }
    }
    
    @IBAction func tappedUpdateAvatar(_ sender: UIButton) {
    }

    @IBAction func tappedSignOut(_ sender: UIButton) {
        self.showAlert(title: LocalizedString(key: "ALERT_CONFIRM_SIGN_OUT"), message: "", cancelTitle: LocalizedString(key: "CANCEL"), okTitle: LocalizedString(key: "OK"), onOKAction: {_ in
            app_delegate.firebaseObject.signOut()
            
            let signInViewController = main_storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            app_delegate.window?.rootViewController = signInViewController
        })
    }
    
    @IBAction func tappedChangePassword(_ sender: UIButton) {
        let changePasswordViewController = main_storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.present(changePasswordViewController, animated: true, completion: nil)
    }
    
    //Hide keyboard
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Function
    func updateProfile(onCompletionHandler: @escaping () -> ()) {
        if (emailTextField.text?.count)! > 0 {
            //Chang email in firebase Authentication
            app_delegate.firebaseObject.changeEmail(newEmail: emailTextField.text!, onCompletionHandler: {error in
                //Update email
                app_delegate.firebaseObject.updateEmail(email: self.emailTextField.text!)
                
                //Update user name
                self.updateUserName()
                
                //Call back after update successfull
                onCompletionHandler()
            })
        } else {
            //Only change user name
            self.updateUserName()
            
            //Call back after update successfull
            onCompletionHandler()
        }
    }
    
    func updateUserName() {
        if (nameTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.updateName(name: nameTextField.text!)
        }
    }
    
    //MARK: - TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = textField as! TextField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 50
    }
}
