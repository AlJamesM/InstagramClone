//
//  SignInViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear BG fields
        instaTextField("Email"   , &emailTextField)
        instaTextField("Password", &passwordTextField)
        
        // Rounded button corners
        signInButton.layer.cornerRadius = 10.0
        signInButton.clipsToBounds      = true
        
        handleTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "signInToTabBarId", sender: nil)
        }
    }
    
    func handleTextField() {
        signInButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        signInButton.isEnabled = false
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // Force dismiss keyboard if background is pressed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange() {
        guard let password = passwordTextField.text, !password.isEmpty, let email = emailTextField.text, !email.isEmpty else {
            signInButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting", interaction: false)
        
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "signInToTabBarId", sender: nil)
        }
    }
}
