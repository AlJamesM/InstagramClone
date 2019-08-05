//
//  Comment.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["comment"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}

