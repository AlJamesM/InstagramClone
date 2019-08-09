//
//  HelperService.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/6/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseStorage

class HelperService {
    static func uploadDataToServer(data: Data, caption: String, onSuccess: @escaping () -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference()
        storageRef.child("posts").child(photoIdString).putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.child("posts").child(photoIdString).downloadURL(completion: { (url, error) in
                guard let downloadURL = url else { return }
                self.sendDataToDatabase(photoUrl : downloadURL.absoluteString, caption: caption, onSuccess: onSuccess)
            })
        })
    }
    
    static func sendDataToDatabase(photoUrl: String, caption: String, onSuccess: @escaping () -> Void) {
        guard let newPostId = Api.Post.REF_POSTS.childByAutoId().key else { return }
        guard let currentUser = Api.User.CURRENT_USER else { return }
        
        let currentUserId = currentUser.uid
        
        Api.Post.REF_POSTS.child(newPostId).setValue(["uid" : currentUserId, "photoUrl" : photoUrl, "caption" : caption, "likecount": 0]) { (error, databaseRef) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            
            let userPostRef = Api.UserPost.REF_USER_POSTS.child(currentUserId).child(newPostId)
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            ProgressHUD.showSuccess("Success")
            onSuccess()
        }
    }
}
