//
//  ProfileViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 9/30/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ProfileViewController: OriginalViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addRightBarItem(imageName: "", title: "Edit")
        self.addTitleNavigation(title: "Profile")
        
        //Add tapGesture to View
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Init Data
    func initData() {
        let password = UserDefaults.standard.object(forKey: "password") as? String

        nameTextField.text = app_delegate.profile.name
        emailTextField.text = app_delegate.profile.email
        passwordTextField.text = password!

        //disable textfield
        nameTextField.isEnabled = false
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
    }
    
    //MARK: Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tappedRightBarButton(sender: UIButton) {
        if !nameTextField.isEnabled {
            //Allow edit profile
            self.addRightBarItem(imageName: "", title: "Save")
            
            nameTextField.isEnabled = true
            emailTextField.isEnabled = true
            passwordTextField.isEnabled = true
        } else {
            //Change profile
            self.showHUD()
            self.updateProfile {
                self.hideHUD()
            }
        }
    }
    
    @IBAction func tappedUpdateAvatar(_ sender: UIButton) {
    }

    @IBAction func tappedSignOut(_ sender: UIButton) {
        self.showAlert(title: "Do you want sign out?", message: "", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            app_delegate.firebaseObject.signOut()
            let rootViewController = self.navigationController?.viewControllers.first
            rootViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func tappedChangePassword(_ sender: UIButton) {
        let changePasswordViewController = main_storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(changePasswordViewController, animated: true)
    }
    
    @IBAction func tappedAbout(_ sender: UIButton) {
        let aboutViewController = main_storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.navigationController?.pushViewController(aboutViewController, animated: true)
    }
    
    //Hide keyboard
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Function
    func updateProfile(onCompletionHandler: @escaping () -> ()) {
        if (passwordTextField.text?.count)! > 0 {
            if (emailTextField.text?.count)! > 0 {
                //Chang email in firebase Authentication
                app_delegate.firebaseObject.changeEmail(newEmail: emailTextField.text!, password: passwordTextField.text!, onCompletionHandler: {error in
                    //Update email infirebase database
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
        } else {
            self.showAlert(title: "Error", message: "Please check again information", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            })
        }
    }
    
    func updateUserName() {
        if (nameTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.updateName(name: nameTextField.text!)
        }
    }
}
