//
//  SignUpViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    var ref : DatabaseReference!
    var storageRef : StorageReference!
    var selectedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        storageRef = Storage.storage().reference()

        // Set Default Image
        selectedImage = UIImage.init(named: "placeholderImg")
        
        // Clear BG fields
        instaTextField("Username", &usernameTextField)
        instaTextField("Email", &emailTextField)
        instaTextField("Password", &passwordTextField)
        
        // Rounded profile picture
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2.0
        profileImageView.clipsToBounds      = true
        
        // Rounded button corners
        signUpButton.layer.cornerRadius = 10.0
        signUpButton.clipsToBounds      = true
        
        // Draw a white ring around the profile image
        let ring = CAShapeLayer.init()
        ring.path = UIBezierPath.init(ovalIn: CGRect(x: 0, y: 0, width: profileImageView.frame.width, height: profileImageView.frame.height)).cgPath
        ring.lineWidth = 2.0
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = UIColor.white.cgColor
        profileImageView.layer.addSublayer(ring)
        profileImageView.isUserInteractionEnabled = true
        
        // Make photo tapable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapImageView))
        profileImageView.addGestureRecognizer(tapGesture)
        
        handleTextField()
    }
    
    func handleTextField() {
        signUpButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        signUpButton.isEnabled = false
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // Force dismiss keyboard if background is pressed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty, let email = emailTextField.text, !email.isEmpty else {
            signUpButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
            signUpButton.isEnabled = false
            return
        }
        
        signUpButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signUpButton.isEnabled = true
    }
    
    @objc func handleTapImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pressDismissButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting", interaction: false)
        
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        guard let userName = usernameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (authDataResult, error) in
            if error != nil {
                if let descError = error?.localizedDescription {
                   ProgressHUD.showError(descError)
                }
                return
            }
            
            guard let user = Auth.auth().currentUser else { return }
            guard let profileImg = self.selectedImage else { return }
            guard let imageData = profileImg.jpegData(compressionQuality: 0.2) else { return }
            self.storageRef.child("profileImage").child(user.uid).putData(imageData, metadata: nil, completion: { (metadata, error) in
                guard let _ = metadata else { return }
                self.storageRef.child("profileImage").child(user.uid).downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else { return }
                    self.ref.child("users").child(user.uid).setValue(["username" : userName, "email" : userEmail, "profileImageUrl" : downloadURL.absoluteString])
                    
                    ProgressHUD.showSuccess("Success")
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
}

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = profileImage
            selectedImage = profileImage
        }
        dismiss(animated: true, completion: nil)
    }
}
