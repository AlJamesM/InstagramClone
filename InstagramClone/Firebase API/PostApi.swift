//
//  PostApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PostApi {
    
    var REF_POSTS = Database.database().reference().child("posts")
    
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        }
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void) {
        REF_POSTS.child(id).observe(.childChanged) { (snapshot) in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        }
    }
    
    func incrementLikes(forRef ref: DatabaseReference, withId id: String, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        ref.child(id).runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                onSuccess(post)
                //self.updateLike(post: post)
            }
        }
    }
}
