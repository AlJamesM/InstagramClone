//
//  DiscoverViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/7/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

    var users: [IUser] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 92.0
        tableView.allowsSelection = false
        
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    func loadUsers() {
        Api.User.observeUsers { (user) in
            Api.Follow.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserProfileSegueId" {
            let userId = sender as! String
            let profileVC = segue.destination as! ProfileUserViewController
            profileVC.userId = userId
        }
    }
}

extension DiscoverViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoverCellReuseId", for: indexPath) as! DiscoverTableViewCell
    
        cell.user = users[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension DiscoverViewController : DiscoverTableViewCellDelegate {
    func openProfileVC(userId: String) {
        self.performSegue(withIdentifier: "UserProfileSegueId", sender: userId)
    }
}
