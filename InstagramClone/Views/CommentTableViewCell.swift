//
//  CommentTableViewCell.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/2/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.text = ""
        commentLabel.text = ""
    }

    func updateView() {
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        if let profilePhotoUrlString = user?.profileImageUrl {
            let profilePhotoUrl = URL(string: profilePhotoUrlString)
            profileImageView.sd_setImage(with: profilePhotoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholderImg")
        usernameLabel.text = ""
    }

}