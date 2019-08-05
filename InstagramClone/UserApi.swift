//
//  UserApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserApi {
    
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUser(uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict)
                completion(user)
            }
        }
    }
}
