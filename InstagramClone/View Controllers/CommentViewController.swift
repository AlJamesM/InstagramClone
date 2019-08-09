//
//  CommentViewController.swift
//  InstagramClone
//
//  Created by Al Manigsaca on 8/2/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var postId : String?
    
    var comments = [Comment]()
    var users = [IUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comment"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        loadComments()

        // Hide and show keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) {
                self.bottomConstraint.constant = -keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadComments() {
        guard let postId = self.postId else { return }
        
        Api.Comment.observeComment(postId: postId) { (comment) in
            self.fetchUser(uid: comment.uid!, completed: {
                self.comments.append(comment)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        handleTextField()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func handleTextField() {
        sendButton.isEnabled = false
        commentTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            sendButton.isEnabled = false
            return
        }
        sendButton.isEnabled = true
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let newCommentId = Api.Comment.REF_COMMENTS.childByAutoId().key else { return }
        guard let currentUser = Api.User.CURRENT_USER else { return }
        let currentUserId = currentUser.uid
        
        Api.Comment.REF_COMMENTS.child(newCommentId).setValue(["uid" : currentUserId, "comment" : commentTextField.text!]) { (error, databaseRef) in
            if error != nil {
                return
            }
            
            guard let postId = self.postId else { return }
            let postCommentsRef = Api.Comment.REF_POST_COMMENTS.child(postId).child(newCommentId)
            postCommentsRef.setValue(true, withCompletionBlock: { (error, reference) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
            })
            self.empty()
            self.view.endEditing(true)
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentToProfileSegue" {
            let userId = sender as! String
            let profileVC = segue.destination as! ProfileUserViewController
            profileVC.userId = userId
        }
    }
    
}

extension CommentViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentTableCell", for: indexPath) as! CommentTableViewCell
        
        cell.comment = comments[indexPath.row]
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension CommentViewController : CommentTableViewCellDelegate {
    func openProfileVC(userId: String) {
        self.performSegue(withIdentifier: "commentToProfileSegue", sender: userId)
    }
}
