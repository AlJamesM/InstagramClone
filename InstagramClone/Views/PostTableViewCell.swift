//
//  PostTableViewCell.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/2/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profielmageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commetImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
//    var postRef : DatabaseReference!
    var homeVC : HomeViewController?
    var post : Post? {
        didSet {
            updateView()
        }
    }
    
    var user: IUser? {
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
        let postRef = Api.Post.REF_POSTS
        Api.Post.incrementLikes(forRef: postRef, withId: post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes // Cache array in the viewCOntroller is updated due to reference passing
            self.post?.isLiked = post.isLiked // Cache array in the viewCOntroller is updated due to reference passing
            self.post?.likeCount = post.likeCount // Cache array in the viewCOntroller is updated due to reference passing
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    func updateView() {
        captionLabel.text = post?.caption
        if let photoUrlString = post?.photoUrl, let photoUrl = URL(string: photoUrlString) {
            postImageView.sd_setImage(with: photoUrl)
        }
        
        self.updateLike(post: self.post!)

        
//        Api.Post.observeLikeCount(withPostId: post!.id!) { (value) in
//            self.likeCountButton.setTitle("\(value) likes", for: UIControl.State.normal)
//        }
    }
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        
        if let count = post.likeCount {
            if count != 0 {
                likeCountButton.setTitle("\(count) likes", for: UIControl.State.normal)
            } else {
                likeCountButton.setTitle("Be the first to like", for: UIControl.State.normal)
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
