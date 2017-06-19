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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSignUp(_ sender: UIButton) {
        if (emailTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0 {
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                let key = app_delegate.firebaseObject.createUser(email:self.emailTextField.text!)
                
                let drawerController = app_delegate.initRevealViewController()
                self.present(drawerController, animated: true, completion: nil)
            }
        }
    }
}
