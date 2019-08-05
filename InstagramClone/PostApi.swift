//
//  PostApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
}
