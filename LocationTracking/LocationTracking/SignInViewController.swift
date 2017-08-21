//
//  SignInViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: OriginalViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var signInGoogleButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tappedDismissKeyboard()
    }

    func CustomLayout() {
        emailView.customBorder(radius: 10)
        passwordView.customBorder(radius: 10)
        signInButton.customBorder(radius: 5)
        signUpButton.customBorder(radius: 5)
        signInFacebookButton.customBorder(radius: 5)
        signInGoogleButton.customBorder(radius: 5)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    @IBAction func tappedSignIn(_ sender: UIButton) {
        if (emailTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0 {
            self.showHUD()
            app_delegate.firebaseObject.signInWith(email: emailTextField.text!, password: passwordTextField.text!, completionHandler: {(isSuccess) in
                self.hideHUD()
                if isSuccess {
                    //SignIn is successful
                    app_delegate.profile = DatabaseManager.getProfile()
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
    
    @IBAction func tappedSignInWithFacebook(_ sender: UIButton) {
        app_delegate.firebaseObject.signInByFacebook(fromViewControlller: self,completionHandler: {isSuccess in
            self.hideHUD()
            if isSuccess {
                //SignIn is successful
                app_delegate.profile = DatabaseManager.getProfile()
                let drawerController = app_delegate.initRevealViewController()
                self.present(drawerController, animated: true, completion: nil)
            } else {
                /*
                 SignIn is failure
                 Show Toast to notify result
                 */
            }
        })
    }
    
    @IBAction func tappedSignInWithGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        if GIDSignIn.sharedInstance().currentUser != nil {
            self.showHUD()
        }
    }
    
    @IBAction func tappedSignWithTwitter(_ sender: UIButton) {
        app_delegate.firebaseObject.signInByTwitter(fromViewControlller: self,completionHandler: {isSuccess in
            self.hideHUD()
            if isSuccess {
                //SignIn is successful
                app_delegate.profile = DatabaseManager.getProfile()
                let drawerController = app_delegate.initRevealViewController()
                self.present(drawerController, animated: true, completion: nil)
            } else {
                /*
                 SignIn is failure
                 Show Toast to notify result
                 */
            }
        })

    }
    
    @IBAction func tappedSignUp(_ sender: UIButton) {
        
    }
    
    //MARK: - Google Sign in Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else { return }
        self.showHUD()
        app_delegate.firebaseObject.signInByGoogle(authentication: authentication,fromViewControlller: self,completionHandler: {isSuccess in
            self.hideHUD()
            if isSuccess {
                //SignIn is successful
                app_delegate.profile = DatabaseManager.getProfile()
                let drawerController = app_delegate.initRevealViewController()
                self.present(drawerController, animated: true, completion: nil)
            } else {
                /*
                 SignIn is failure
                 Show Toast to notify result
                 */
            }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
}
