//
//  AdminViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/24/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class AdminViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredUsers:[User] = []
    var users:[User] = []
//    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")

    //=========================================================================
    //MARK - VIEWDIDLOAD/SETUP
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        loadUsers("")
        
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUsers(_ searchText: String) {
        users = []
        root?.child(byAppendingPath: "users").observeSingleEvent(of: .value, with: { snapshot in
            for uidsnapshot in snapshot.children {
                let user = User(snapshot: uidsnapshot as! FIRDataSnapshot)
                if !user.admin {
                    self.users.append(user)
                }
            }
            self.reloadTable(searchText)
        })
    }
    
    //===========================================================================
    //MARK - STATUSBAR
    //===========================================================================
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
    }

}

extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    //=========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminCell", for: indexPath) as! AdminCell
        cell.backgroundColor = StyleConstants.defaultGrayColor
        let user = filteredUsers[indexPath.row]
        cell.emailLabel.text = user.email
        cell.emailLabel.textColor = UIColor.white
        if user.banned {
            cell.statusLabel.text = "BANNED"
            cell.statusLabel.textColor = UIColor.red
        } else if user.locked {
            cell.statusLabel.text = "LOCKED"
            cell.statusLabel.textColor = UIColor.yellow
        } else {
            cell.statusLabel.text = "ACTIVE"
            cell.statusLabel.textColor = UIColor.green
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = filteredUsers[indexPath.row]
        let banAction = UITableViewRowAction(style: .normal, title: "BAN", handler: {action, indexPath in
            root?.child(byAppendingPath: "users/\(user.uid)/banned").setValue("true")
            self.loadUsers(self.searchBar.text!)
        })
        let unbanAction = UITableViewRowAction(style: .normal, title: "UNBAN", handler: { action, indexPath in
            root?.child(byAppendingPath: "users/\(user.uid)/banned").setValue("false")
            self.loadUsers(self.searchBar.text!)
        })
        let lockAction = UITableViewRowAction(style: .normal, title: "LOCK", handler: {action, indexPath in
            root?.child(byAppendingPath: "users/\(user.uid)/locked").setValue("true")
            self.loadUsers(self.searchBar.text!)
        })
        let unlockAction = UITableViewRowAction(style: .normal, title: "UNLOCK", handler: {action, indexPath in
            root?.child(byAppendingPath: "users/\(user.uid)/locked").setValue("false")
            self.loadUsers(self.searchBar.text!)
        })
        if user.banned {
            return [unbanAction]
        } else if user.locked {
            return [banAction, unlockAction]
        } else {
            return [banAction, lockAction]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func reloadTable(_ searchText: String) {
        //filter
        if searchText == "" {
            filteredUsers = users
        } else {
            filteredUsers = users.filter({user in
                return user.email.contains(searchText)
            })
        }
        self.tableView.reloadData()
    }
    

    
}

extension AdminViewController: UISearchBarDelegate {
    //=========================================================================
    //MARK - SEARCHBAR
    //===========================================================================
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadTable(searchText)
    }
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
