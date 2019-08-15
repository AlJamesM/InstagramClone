//
//  SettingTableViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/12/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var ref : DatabaseReference!
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        fetchCurrentUser()
        
        tableView.allowsSelection = false
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
    }
    
    func fetchCurrentUser() {
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username!
            self.emailTextField.text = user.email!
            if let profileUrl = URL(string: user.profileImageUrl!) {
                self.profileImageView.sd_setImage(with: profileUrl)
            }
        }
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        
        view.endEditing(true)
        ProgressHUD.show("Waiting", interaction: false)
        
        guard let userEmail = emailTextField.text else { return }
        guard let userName = usernameTextField.text else { return }
        guard let user = Api.User.CURRENT_USER else { return }
        guard let profileImg = self.profileImageView.image else { return }
        guard let imageData = profileImg.jpegData(compressionQuality: 0.2) else { return }
        
        self.storageRef.child("profileImage").child(user.uid).putData(imageData, metadata: nil, completion: { (metadata, error) in
            guard let _ = metadata else { return }
            self.storageRef.child("profileImage").child(user.uid).downloadURL(completion: { (url, error) in
                
                guard let downloadURL = url else { return }
                let trimmedUsername = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                self.ref.child("users").child(user.uid).setValue(["username" : trimmedUsername, "username_lowercase" : trimmedUsername.lowercased(),"email" : userEmail, "profileImageUrl" : downloadURL.absoluteString])
                
                ProgressHUD.showSuccess("Success")
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        AuthService.logout(onSucccess: {
            self.dismiss(animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func changeProfileImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension SettingTableViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = profileImage
        }
        dismiss(animated: true, completion: nil)
    }
}
