//
//  HeaderProfileCollectionReusableView.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/6/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: IUser)
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var user: IUser? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        self.nameLabel.text = user!.username
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImageView.sd_setImage(with: photoUrl)
        }
        
        Api.UserPost.fetchCountUserPost(userId: user!.id!) { (count) in
            self.postCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        if user?.id == Api.User.CURRENT_USER?.uid {
            self.profileButton.setTitle("Edit Profile", for: UIControl.State.normal)
        } else {
            updateStateButton()
        }
    }
    
    func updateStateButton() {
        if user!.isFollowing! {
            configureUnFollowing()
        } else {
            configureFollowing()
        }
    }
    
    func configureFollowing() {
        profileButton.layer.borderColor = CustomColor.Main.cgColor
        profileButton.layer.borderWidth = 1.0
        profileButton.layer.cornerRadius = 4
        profileButton.clipsToBounds = true
        profileButton.setTitleColor(CustomColor.Main, for: UIControl.State.normal)
        profileButton.backgroundColor = UIColor.white
        
        profileButton.setTitle("Follow", for: UIControl.State.normal)
        profileButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnFollowing() {
        profileButton.layer.borderColor = CustomColor.Main.cgColor
        profileButton.layer.borderWidth = 1.0
        profileButton.layer.cornerRadius = 4
        profileButton.clipsToBounds = true
        profileButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        profileButton.backgroundColor = CustomColor.Main
        
        profileButton.setTitle("Following", for: UIControl.State.normal)
        profileButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        Api.Follow.followAction(withUser: user!.id!)
        configureUnFollowing()
        user!.isFollowing! = true // Updates by reference the array content in the controller
        delegate?.updateFollowButton(forUser: user!)
    }
    
    @objc func unFollowAction() {
        Api.Follow.unFollowAction(withUser: user!.id!)
        configureFollowing()
        user!.isFollowing! = false // Updates by reference the array content in the controller
        delegate?.updateFollowButton(forUser: user!)
    }
}
