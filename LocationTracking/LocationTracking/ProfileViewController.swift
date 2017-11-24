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
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
        self.addTitleNavigation(title: "Profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedUpdateAvatar(_ sender: UIButton) {
    }

    @IBAction func tappedSignOut(_ sender: UIButton) {
        self.showAlert(title: "", message: "Do you want sign out?", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            app_delegate.firebaseObject.signOut()
            let rootViewController = self.navigationController?.viewControllers.first
            rootViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func tappedUpdateProfile(_ sender: UIButton) {
        if (oldPasswordTextField.text?.characters.count)! > 0 && (newPasswordTextField.text?.characters.count)! > 0 {
            //Show loading 
            self.showHUD()

            app_delegate.firebaseObject.changePassword(oldPassword: oldPasswordTextField.text!, newPassword: newPasswordTextField.text!, onCompletionHandler: {error in
                //Hide loading
                self.hideHUD()
                
                if error != nil {
                    self.showAlert(title: "", message: (error?.localizedDescription)!, cancelTitle: "", okTitle: "OK", onOKAction: {_ in
                        
                    })
                } else {
                    self.view.makeToast("Changed password successfully", duration: 1.5, position: .center)
                    self.oldPasswordTextField.text = ""
                    self.newPasswordTextField.text = ""
                }
            })
        } else {
            self.showAlert(title: "Error", message: "Please input old password and new password", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            })
        }

    }
}
