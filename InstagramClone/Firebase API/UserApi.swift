//
//  UserApi.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/3/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserApi {
    
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUser(uid: String, completion: @escaping (IUser) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = IUser.transformUser(dict: dict)
                completion(user)
            }
        }
    }
    
    func observeCurrentUser(completion: @escaping (IUser) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = IUser.transformUser(dict: dict)
                completion(user)
            }
        }
    }
    
    var CURRENT_USER: User?  {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        return nil
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
}
