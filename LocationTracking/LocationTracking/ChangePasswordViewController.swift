//
//  ChangePasswordViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 11/29/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class ChangePasswordViewController: OriginalViewController {

    @IBOutlet weak var oldPasswordTextfield: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ico_back", title: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    override func tappedLeftBarButton(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tappedChangePassword(_ sender: UIButton) {
        
        if (oldPasswordTextfield.text?.count)! > 0 && (newPasswordTextField.text?.count)! > 0 && newPasswordTextField.text == confirmNewPasswordTextField.text {
            //Show loading
            self.showHUD()
            
            app_delegate.firebaseObject.changePassword(oldPassword: oldPasswordTextfield.text!, newPassword: newPasswordTextField.text!, onCompletionHandler: {error in
                //Hide loading
                self.hideHUD()
                
                if error != nil {
                    self.showAlert(title: "", message: (error?.localizedDescription)!, cancelTitle: "", okTitle: "OK", onOKAction: {_ in
                        
                    })
                } else {
                    //Update password at Userdefault
                    self.view.makeToast("Changed password successfully", duration: 1.5, position: .center)
                    self.oldPasswordTextfield.text = ""
                    self.newPasswordTextField.text = ""
                    self.confirmNewPasswordTextField.text = ""
                }
            })
        } else {
            self.showAlert(title: "Error", message: "Please check again old password, new password and confirm password", cancelTitle: "Cancel", okTitle: "OK", onOKAction: {_ in
            })
        }
    }
}
