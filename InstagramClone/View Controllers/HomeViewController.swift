//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [IUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loadPosts() {
        Api.Feed.observeFeed(withId: Api.User.CURRENT_USER!.uid) { (post) in
            guard let postId = post.uid else { return }
            self.fetchUser(uid: postId, completed: {
                self.posts.append(post)
                self.tableView.reloadData()
            })
        }
        
        Api.Feed.observeFeedRemoved(withId: Api.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id != post.uid}
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(uid: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        AuthService.logout(onSucccess: {
            self.dismiss(animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openCommentSegue" {
            let postId = sender as! String
            let commentVC = segue.destination as! CommentViewController
            commentVC.postId = postId
        }
        
        if segue.identifier == "profileUserSegueId" {
            let userId = sender as! String
            let profileVC = segue.destination as! ProfileUserViewController
            profileVC.userId = userId
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifierPostCell", for: indexPath) as! PostTableViewCell
        
        cell.post = posts[indexPath.row] //instead of cell.updateView(post: post)
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: PostTableViewCellDelegate {
    func goToCommentVC(postId: String) {
        self.performSegue(withIdentifier: "openCommentSegue", sender: postId)
    }
    
    func openProfileVC(userId: String) {
        self.performSegue(withIdentifier: "profileUserSegueId", sender: userId)
    }
}
