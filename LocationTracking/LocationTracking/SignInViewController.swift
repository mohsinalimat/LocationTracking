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
    @IBOutlet weak var signInTwitterButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        let password = UserDefaults.standard.object(forKey: "password") as? String
        //Auto login
        if userName != nil && password != nil {
            self.showHUD()
        }
        
        view.tappedDismissKeyboard()
        self.CustomLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.hideHUD()
    }
    
    //MARK: - Function
    func CustomLayout() {
        emailView.customBorder(radius: 3,color: .clear)
        passwordView.customBorder(radius: 3,color: .clear)
        signInButton.customBorder(radius: 3,color: .clear)
        signUpButton.customBorder(radius: 3,color: .clear)
        signInFacebookButton.customBorder(radius: 3,color: .clear)
        signInGoogleButton.customBorder(radius: 3,color: .clear)
        signInTwitterButton.customBorder(radius: 3,color: .clear)
    }
    
    func resetTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Action
    @IBAction func tappedShowPassword(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func tappedForgotPassword(_ sender: UIButton) {
        if (emailTextField.text?.count)! > 0 {
            app_delegate.firebaseObject.resetPassword(email: emailTextField.text!, onComplehandler: {_ in
                self.showAlert(title: "", message: "New password sent to your email, please check your email.", cancelTitle: "", okTitle: "OK",onOKAction: {_ in
                
                })
            })
        } else {
            self.showAlert(title: "", message: "Please input your email", cancelTitle: "", okTitle: "OK", onOKAction: {_ in
            
            })
        }
    }
    
    @IBAction func tappedSignIn(_ sender: UIButton) {
        if (emailTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0 {
            self.showHUD()
            app_delegate.firebaseObject.signInWith(email: emailTextField.text!, name: nil, password: passwordTextField.text!, completionHandler: {(isSuccess) in
                self.hideHUD()
                if isSuccess {
                    //SignIn is successful
                    app_delegate.profile = DatabaseManager.getProfile()
                    self.resetTextField()
                    let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                    let nav = UINavigationController.init(rootViewController: mapViewController)
                    self.present(nav, animated: true, completion: nil)
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
                let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let nav = UINavigationController.init(rootViewController: mapViewController)
                self.present(nav, animated: true, completion: nil)
            } else {
                /*
                 SignIn is failure
                 Show Toast to notify result
                 */
            }
        })
    }
    
    @IBAction func tappedSignInWithGoogle(_ sender: UIButton) {
        self.showHUD()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        if GIDSignIn.sharedInstance().currentUser == nil {
            self.hideHUD()
        }
    }
    
    @IBAction func tappedSignWithTwitter(_ sender: UIButton) {
        app_delegate.firebaseObject.signInByTwitter(fromViewControlller: self,completionHandler: {isSuccess in
            self.hideHUD()
            if isSuccess {
                //SignIn is successful
                app_delegate.profile = DatabaseManager.getProfile()
                let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let nav = UINavigationController.init(rootViewController: mapViewController)
                self.present(nav, animated: true, completion: nil)
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
                let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let nav = UINavigationController.init(rootViewController: mapViewController)
                self.present(nav, animated: true, completion: nil)
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
