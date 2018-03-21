//
//  SplashViewController.swift
//  LocationTracking
//
//  Created by Thuy Phan on 3/21/18.
//  Copyright © 2018 Nguyen Hai Dang. All rights reserved.
//

import UIKit

class SplashViewController: OriginalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoSignIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: - Sign in
    func autoSignIn() {
        let userName = UserDefaults.standard.object(forKey: "userName") as? String
        let password = UserDefaults.standard.object(forKey: "password") as? String
        
        if userName != nil && password != nil {
            self.showHUD()
            
            app_delegate.firebaseObject.signInWith(email: userName!, name:nil, password: password!, completionHandler: {(isSuccess) in
                
                let mapViewController = main_storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let nav = UINavigationController.init(rootViewController: mapViewController)
                
                self.hideHUD()
                self.present(nav, animated: true, completion: nil)
            })
        } else {
            let signInViewController = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.present(signInViewController, animated: true, completion: nil)
        }
    }
}
