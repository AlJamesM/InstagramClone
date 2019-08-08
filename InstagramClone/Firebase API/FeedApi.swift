//
//  FeedApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/7/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedApi {
    
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        }
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        }
    }
}
