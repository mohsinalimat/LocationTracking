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
    @IBOutlet weak var aboutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
        
        //Add tapGesture to View
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Set up UI
    func setupUI() {
        changePasswordButton.customBorder(radius: changePasswordButton.frame.height/2, color: Common.mainColor())
        aboutButton.customBorder(radius: aboutButton.frame.height/2, color: .clear)
        nameTextField.customBorder(radius: nameTextField.frame.height/2, color: .clear)
        emailTextField.customBorder(radius: emailTextField.frame.height/2, color: .clear)
        
        nameTextField.textRect(forBounds: nameTextField.bounds)
        emailTextField.textRect(forBounds: emailTextField.bounds)
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
    
    @IBAction func tappedUpdateAvatar(_ sender: UIButton) {
    }

    @IBAction func tappedSignOut(_ sender: UIButton) {
        self.showAlert(title: "Do you want sign out?", message: "", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            app_delegate.firebaseObject.signOut()
            
            let signInViewController = main_storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            app_delegate.window?.rootViewController = signInViewController
        })
    }
    
    @IBAction func tappedChangePassword(_ sender: UIButton) {
        let changePasswordViewController = main_storyboard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.present(changePasswordViewController, animated: true, completion: nil)
    }
    
    @IBAction func tappedAbout(_ sender: UIButton) {
        let aboutViewController = main_storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        self.present(aboutViewController, animated: true, completion: nil)
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
}
