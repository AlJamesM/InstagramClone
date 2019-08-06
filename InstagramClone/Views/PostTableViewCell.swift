//
//  PostTableViewCell.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/2/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profielmageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commetImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var homeVC: HomeViewController?
    var post: Post? {
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
        nameLabel.text    = ""
        captionLabel.text = ""
        
        let tapGestureComment = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCommentImageView))
        commetImageView.addGestureRecognizer(tapGestureComment)
        commetImageView.isUserInteractionEnabled = true
        
        let tapGestureLike = UITapGestureRecognizer(target: self, action: #selector(self.handleTapLikeImageView))
        likeImageView.addGestureRecognizer(tapGestureLike)
        likeImageView.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTapCommentImageView() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "openCommentSegue", sender: id)
        }
    }
    
    @objc func handleTapLikeImageView() {
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("likes").child(post!.id!).observeSingleEvent(of: .value) { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    Api.User.REF_USERS.child(currentUser.uid).child("likes").child(self.post!.id!).setValue(true)
                    self.likeImageView.image = UIImage(named: "likeSelected")
                } else {
                    Api.User.REF_USERS.child(currentUser.uid).child("likes").child(self.post!.id!).removeValue()
                    self.likeImageView.image = UIImage(named: "like")
                }
            }
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl, let photoUrl = URL(string: photoUrlString) {
            postImageView.sd_setImage(with: photoUrl)
        }
        captionLabel.text = post?.caption
        
        if let currentUser = Auth.auth().currentUser {
            Api.User.REF_USERS.child(currentUser.uid).child("likes").child(post!.id!).observeSingleEvent(of: .value) { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                    self.likeImageView.image = UIImage(named: "like")
                } else {
                    self.likeImageView.image = UIImage(named: "likeSelected")
                }
            }
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let profilePhotoUrlString = user?.profileImageUrl {
            let profilePhotoUrl = URL(string: profilePhotoUrlString)
            profielmageView.sd_setImage(with: profilePhotoUrl, placeholderImage: UIImage(named: "placeholderImg"))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profielmageView.image = UIImage(named: "placeholderImg")
        nameLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
