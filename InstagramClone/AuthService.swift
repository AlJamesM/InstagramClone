//
//  AuthService.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/6/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthService {
    
    static func logout( onSucccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSucccess()
        } catch let logOutError {
            onError(logOutError.localizedDescription)
        }
    }
}
