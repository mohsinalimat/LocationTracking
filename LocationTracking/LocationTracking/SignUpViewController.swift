//
//  SignUpViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: OriginalViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.customBorder(radius: 5)
        self.addLeftBarItem(imageName: "ic_close_popup",title: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - IBAction
    @IBAction func tappedSignUp(_ sender: UIButton) {
        if (emailTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0 && (confirmPasswordTextField.text?.characters.count)! > 0 && confirmPasswordTextField.text == passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                //Create new user on firebase
                let id = app_delegate.firebaseObject.createUser(email:self.emailTextField.text!)
                //Create profile in database
                DatabaseManager.updateProfile(id:id, email:self.emailTextField.text!, latitude: 0, longitude: 0,onCompletionHandler: {_ in
                    //Present after updated profile
                    app_delegate.profile = DatabaseManager.getProfile()
                    let drawerController = app_delegate.initRevealViewController()
                    self.present(drawerController, animated: true, completion: nil)
                })
            }
        } else {
            view.makeToast("Please input correct information", duration: 2.0, position: .center)
        }
    }
}
