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

    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var confirmPasswordTextField: TextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarItem(imageName: "ic_close_popup",title: "")
        view.tappedDismissKeyboard()
        self.CustomLayout()
        self.registerKeyboardEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupLanguage()
    }
    
    func CustomLayout() {
        signUpButton.isExclusiveTouch = true
        signUpButton.customBorder(radius: signUpButton.frame.height/2,color: .clear)
        emailTextField.customBorder(radius: emailTextField.frame.height/2,color: .clear)
        confirmPasswordTextField.customBorder(radius: confirmPasswordTextField.frame.height/2,color: .clear)
        nameTextField.customBorder(radius: nameTextField.frame.height/2,color: .clear)
        passwordTextField.customBorder(radius: passwordTextField.frame.height/2,color: .clear)
        
        emailTextField.textRect(forBounds: emailTextField.bounds)
        nameTextField.textRect(forBounds: nameTextField.bounds)
        passwordTextField.textRect(forBounds: passwordTextField.bounds)
        confirmPasswordTextField.textRect(forBounds: confirmPasswordTextField.bounds)
    }
    
    func setupLanguage() {
        emailTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_EMAIL")
        nameTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_NAME")
        passwordTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_PASSWORD")
        confirmPasswordTextField.placeholder = LocalizedString(key: "PLACE_HOLDER_CONFIRM_PASSWORD")

        signUpButton.setTitle(LocalizedString(key: "SIGN_UP"), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Keyboard
    override func keyboardEventWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: signUpButton.frame.origin.y + signUpButton.frame.height + keyboardSize.height + 20)
        if keyboardSize.height > (scrollView.frame.height - confirmPasswordTextField.frame.origin.y - confirmPasswordTextField.frame.height) {
            scrollView.contentOffset = CGPoint.init(x: 0, y: keyboardSize.height - (scrollView.frame.height - confirmPasswordTextField.frame.origin.y - confirmPasswordTextField.frame.height))
        }
    }
    
    override func keyboardEventWillHide(_ notification: Notification) {
        scrollView.contentSize = CGSize.init(width: scrollView.frame.width, height: signUpButton.frame.height + signUpButton.frame.origin.y + 20)
    }
    
    //MARK: - Action
    
    @IBAction func tappedDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - IBAction
    @IBAction func tappedSignUp(_ sender: UIButton) {
        self.showHUD()
        
        if (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0 && (confirmPasswordTextField.text?.count)! > 0 && (nameTextField.text?.count)! > 0 && confirmPasswordTextField.text == passwordTextField.text {
            if (passwordTextField.text?.count)! < 6 {
                self.showAlert(title: "", message: LocalizedString(key: "TOAST_PASSWORD_LENGTH"), cancelTitle: "", okTitle: LocalizedString(key: "OK"), onOKAction: {_ in
                    
                })
                self.hideHUD()
                return
            }
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    self.view.makeToast((error?.localizedDescription)!, duration: 2.0, position: .center)
                    self.hideHUD()
                    return
                }
                
                //Create new user on firebase
                app_delegate.firebaseObject.registerNewAccount(email: self.emailTextField.text!, password: self.passwordTextField.text!,name: self.nameTextField.text!,  onCompletionHandler: {id in

                    let dict = ["email": self.emailTextField.text!, "name": self.nameTextField.text!, "id": id]
                    app_delegate.profile.initContactModel(dict: dict)
                    
                    //Present after updated profile
                    self.dismiss(animated: false, completion: {_ in
                        let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                        let nav = UINavigationController.init(rootViewController: mapViewController)
                        
                        let visibleViewController: UIViewController = Common.getVisibleViewController(UIApplication.shared.keyWindow?.rootViewController)!
                        visibleViewController.present(nav, animated: true, completion: nil)
                        self.hideHUD()
                    })
                })
            }
        } else {
            self.hideHUD()
            view.makeToast(LocalizedString(key: "ALERT_INFO_SIGN_UP"), duration: 2.0, position: .center)
        }
    }
    
    //MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 50
    }
}
