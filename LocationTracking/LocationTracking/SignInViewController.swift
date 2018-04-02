//
//  SignInViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/17/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SignInViewController: OriginalViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        let password = UserDefaults.standard.object(forKey: "password") as? String
        //Auto login
        
        view.tappedDismissKeyboard()
        self.CustomLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.hideHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
    }
    
    //MARK: - Function
    func CustomLayout() {
        emailView.customBorder(radius: emailView.frame.height/2,color: .clear)
        passwordView.customBorder(radius: passwordView.frame.height/2,color: .clear)
        emailTextField.customBorder(radius: emailTextField.frame.height/2,color: .clear)
        passwordTextField.customBorder(radius: passwordTextField.frame.height/2,color: .clear)
        showPasswordButton.customBorder(radius: showPasswordButton.frame.height/2,color: .clear)

        signInButton.customBorder(radius: signInButton.frame.height/2,color: .clear)
    }
    
    func setupLanguage() {
        passwordTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_PASSWORD")
        emailTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_EMAIL")
        
        signInButton.setTitle(LocalizedString(key: "SIGN_IN"), for: .normal)
        signUpButton.setTitle(LocalizedString(key: "SIGN_UP"), for: .normal)
    }
    
    func resetTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func keyboardEventWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: scrollView.frame.height + keyboardSize.height)
    }
    
    override func keyboardEventWillHide(_ notification: Notification) {
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: scrollView.frame.height)
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
        if (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0 {
            self.showHUD()
            app_delegate.firebaseObject.signInWith(email: emailTextField.text!, name: nil, password: passwordTextField.text!, completionHandler: {(isSuccess) in
                self.hideHUD()
                if isSuccess {
                    //SignIn is successful
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
    
    @IBAction func tappedSignUp(_ sender: UIButton) {
        
    }
}
