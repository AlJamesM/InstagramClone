//
//  PhotoViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class PhotoViewController: UIViewController {

    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    var selectedImage : UIImage?
    
    //var ref : DatabaseReference!
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapImageView))
        photoView.addGestureRecognizer(tapGesture)
        photoView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    @objc func handleTapImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func handlePost() {
        if selectedImage != nil {
            shareButton.isEnabled = true
            removeButton.isEnabled = true
            shareButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        } else {
            shareButton.isEnabled = false
            removeButton.isEnabled = false
            shareButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: UIBarButtonItem) {
        self.captionTextView.text = ""
        self.selectedImage = nil
        self.photoView.image = UIImage(named: "Placeholder-image")
        handlePost()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    
        ProgressHUD.show("Waiting", interaction: false)
        if let photoImage = self.selectedImage, let photoData = photoImage.jpegData(compressionQuality: 0.2) {
            
            //guard let user = Auth.auth().currentUser else { return }
            let photoIdString = NSUUID().uuidString
            
            self.storageRef.child("posts").child(photoIdString).putData(photoData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                self.storageRef.child("posts").child(photoIdString).downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else { return }
                    self.sendDataToDatabase(photoUrl : downloadURL.absoluteString)
                })
            })
        } else {
            ProgressHUD.showError("Image Error")
        }
    }
    
    func sendDataToDatabase(photoUrl : String) {
        
        guard let newPostId = Api.Post.REF_POSTS.childByAutoId().key else { return }
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserId = currentUser.uid
        
        Api.Post.REF_POSTS.child(newPostId).setValue(["uid" : currentUserId, "photoUrl" : photoUrl, "caption" : captionTextView.text!]) { (error, databaseRef) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
            }
            
            let userPostRef = Api.UserPost.REF_USER_POST.child(currentUserId).child(newPostId)
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            ProgressHUD.showSuccess("Success")
            self.captionTextView.text = ""
            self.selectedImage = nil
            self.photoView.image = UIImage(named: "Placeholder-image")
            self.tabBarController?.selectedIndex = 0
        }
    }
}

extension PhotoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photoImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoView.image = photoImage
            selectedImage   = photoImage
            self.handlePost()
        }
        dismiss(animated: true, completion: nil)
    }
}
