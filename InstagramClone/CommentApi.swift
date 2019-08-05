//
//  CommentApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    
    var REF_COMMENTS = Database.database().reference().child("comments")
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    func observeComment(postId: String, completion: @escaping (Comment) -> Void) {
        self.REF_POST_COMMENTS.child(postId).observe(.childAdded) { (snapshot) in
            self.REF_COMMENTS.child(snapshot.key).observeSingleEvent(of: .value) { (commentSnapshot) in
                if let dict = commentSnapshot.value as? [String : Any] {
                    let newComment = Comment.transformComment(dict: dict)
                    completion(newComment)
                }
            }
        }
    }
}
