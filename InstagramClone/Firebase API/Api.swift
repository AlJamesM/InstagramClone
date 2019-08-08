//
//  Api.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var UserPost = UserPostApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
}
