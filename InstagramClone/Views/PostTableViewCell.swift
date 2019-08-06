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
import FirebaseDatabase

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profielmageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commetImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var postRef : DatabaseReference!
    var homeVC : HomeViewController?
    var post : Post? {
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
        postRef = Api.Post.REF_POSTS.child(post!.id!)
        incrementLikes(forRef: postRef)
    }
    
    func incrementLikes(forRef ref: DatabaseReference) {
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                self.updateLike(post: post)
            }
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl, let photoUrl = URL(string: photoUrlString) {
            postImageView.sd_setImage(with: photoUrl)
        }
        captionLabel.text = post?.caption
        updateLike(post: post!)
        
        Api.Post.REF_POSTS.child(post!.id!).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                self.updateLike(post: post)
            }
        }
        Api.Post.REF_POSTS.child(post!.id!).observe(.childChanged) { (snapshot) in
            if let value = snapshot.value as? Int {
                self.likeCountButton.setTitle("\(value) likes", for: UIControl.State.normal)
            }
        }
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
