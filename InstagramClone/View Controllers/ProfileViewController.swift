//
//  ProfileViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: IUser!
    var posts: [Post] = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        fetchUser()
        fetchUserPost()
    }
    
    func fetchUser() {
        Api.User.observeCurrentUser { (user) in
            self.user = user
            self.navigationItem.title = self.user.username
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserPost() {
        guard let currentUser = Api.User.CURRENT_USER else { return }
        Api.UserPost.REF_USER_POST.child(currentUser.uid).observe(.childAdded) { (snapshot) in
            Api.Post.observePost(withId: snapshot.key, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCellViewId", for: indexPath) as! PhotoCollectionViewCell
        
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "collectionViewHeaderId", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
        }
        return headerViewCell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width/3 - 0.5, height: collectionView.frame.size.width/3 - 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
