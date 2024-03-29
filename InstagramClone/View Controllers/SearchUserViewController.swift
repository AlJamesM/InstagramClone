//
//  SearchUserViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/8/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController {

    var searchBar = UISearchBar()
    var users: [IUser] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func doSearch() {
        if let searchText = searchBar.text {
            self.users.removeAll()
            self.tableView.reloadData()
            Api.User.queryUsers(withText: searchText.lowercased()) { (user) in
                Api.Follow.isFollowing(userId: user.id!, completed: { (value) in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileFromDiscoverSegue" {
            let userId = sender as! String
            let profileVC = segue.destination as! ProfileUserViewController
            profileVC.userId = userId
            profileVC.delegate = self
        }
    }
}

extension SearchUserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
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

extension SearchUserViewController: DiscoverTableViewCellDelegate {
    func openProfileVC(userId: String) {
        self.performSegue(withIdentifier: "profileFromDiscoverSegue", sender: userId)
    }
}

extension SearchUserViewController: HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: IUser) {
        for u in self.users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
