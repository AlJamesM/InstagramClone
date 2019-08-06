//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 7/29/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [User]()
    
    var databaseRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        
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
        activityView.startAnimating()
        Api.Post.observePosts { (post) in
            guard let postId = post.uid else { return }
            self.fetchUser(uid: postId, completed: {
                self.posts.append(post)
                self.activityView.stopAnimating()
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Api.User.observeUser(uid: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        print("LogOut Pressed")
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openCommentSegue" {
            let postId = sender as! String
            let commentVC = segue.destination as! CommentViewController
            commentVC.postId = postId
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
        cell.homeVC = self
        return cell
    }
}
