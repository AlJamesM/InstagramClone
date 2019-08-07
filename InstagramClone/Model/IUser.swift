//
//  User.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/2/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation

class IUser {
    var email: String?
    var profileImageUrl: String?
    var username: String?
}

extension IUser {
    static func transformUser(dict: [String: Any]) -> IUser {
        let user = IUser()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        return user
    }
}
