//
//  Post.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/31/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation

class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
}

extension Post {
    static func transformPost(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.uid = dict["uid"] as? String
        return post
    }
}
