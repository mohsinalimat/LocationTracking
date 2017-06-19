//
//  SignInViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SignInViewController: OriginalViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var signInGoogleButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.setupBorder()
        signUpButton.setupBorder()
        signInFacebookButton.setupBorder()
        signInGoogleButton.setupBorder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSignIn(_ sender: UIButton) {
        if (emailTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0 {
            app_delegate.firebaseObject.signInWith(email: emailTextField.text!, password: passwordTextField.text!, completionHandler: {(isSuccess) in
                if isSuccess {
                    //SignIn is successful
                    let drawerController = app_delegate.initRevealViewController()
                    self.present(drawerController, animated: true, completion: nil)
                } else {
                    /*
                     SignIn is failure
                     Show Toast to notify result
                    */
                    self.view.makeToast("Email or password is wrong.\n Please check again.", duration: 2.0, position: .center)
                }
            })
        }
    }
    
    @IBAction func tappedSignUp(_ sender: UIButton) {
    }
}
