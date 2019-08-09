//
//  UserPostApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/6/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserPostApi {
    
    var REF_USER_POSTS = Database.database().reference().child("userPost")

    func fetchUserPost(userId: String, completion: @escaping (String) -> Void) {
        REF_USER_POSTS.child(userId).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
    
    func fetchCountUserPost(userId: String, completion: @escaping (Int) -> Void ) {
        REF_USER_POSTS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
}
