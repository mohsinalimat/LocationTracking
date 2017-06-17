//
//  SignUpViewController.swift
//  LocationTracking
//
//  Created by Nguyen Hai Dang on 6/18/17.
//  Copyright © 2017 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SignUpViewController: OriginalViewController {

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
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
        if (nickNameTextField.text?.characters.count)! > 0 && (userNameTextField.text?.characters.count)! > 0 {
            let birthday: String = (birthdayTextField.text?.characters.count)! > 0 ? birthdayTextField.text! : ""
            app_delegate.firebaseObject.createUser(nickName: nickNameTextField.text!, userName: userNameTextField.text!, birthday: birthday)
            let drawerController = app_delegate.initRevealViewController()
            self.present(drawerController, animated: true, completion: nil)
        }
    }
}
