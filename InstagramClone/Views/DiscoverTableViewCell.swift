//
//  DiscoverTableViewCell.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/7/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

protocol DiscoverTableViewCellDelegate {
    func openProfileVC(userId: String)
}

class DiscoverTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: DiscoverTableViewCellDelegate?
    
    var user: IUser? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGestureUsername = UITapGestureRecognizer(target: self, action: #selector(self.handleTapUsername))
        nameLabel.addGestureRecognizer(tapGestureUsername)
        nameLabel.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTapUsername() {
        if let id = user?.id {
            self.delegate?.openProfileVC(userId: id)
        }
    }
    
    
    func updateView() {
        nameLabel.text = user?.username
        if let profilePhotoUrlString = user?.profileImageUrl {
            let profilePhotoUrl = URL(string: profilePhotoUrlString)
            profileImage.sd_setImage(with: profilePhotoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
        
        if user!.isFollowing! {
            configureUnFollowing()
        } else {
            configureFollowing()
        }
    }
    
    func configureFollowing() {
        followButton.layer.borderColor = CustomColor.Main.cgColor
        followButton.layer.borderWidth = 1.0
        followButton.layer.cornerRadius = 4
        followButton.clipsToBounds = true
        followButton.setTitleColor(CustomColor.Main, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor.white
        
        followButton.setTitle("Follow", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnFollowing() {
        followButton.layer.borderColor = CustomColor.Main.cgColor
        followButton.layer.borderWidth = 1.0
        followButton.layer.cornerRadius = 4
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        followButton.backgroundColor = CustomColor.Main
        
        followButton.setTitle("Following", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        Api.Follow.followAction(withUser: user!.id!)
        configureUnFollowing()
        user!.isFollowing! = true // Updates by reference the array content in the controller
    }
    
    @objc func unFollowAction() {
        Api.Follow.unFollowAction(withUser: user!.id!)
        configureFollowing()
        user!.isFollowing! = false // Updates by reference the array content in the controller
    }
}
