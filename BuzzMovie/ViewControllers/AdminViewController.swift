//
//  AdminViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/24/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase


class AdminViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredUsers:[User] = []
    var users:[User] = []
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")

    //=========================================================================
    //MARK - VIEWDIDLOAD/SETUP
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.autocapitalizationType = .None
        searchBar.autocorrectionType = .No
        loadUsers("")
        
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUsers(searchText: String) {
        users = []
        root.childByAppendingPath("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            for uidsnapshot in snapshot.children {
                let user = User(snapshot: uidsnapshot as! FDataSnapshot)
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
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.resignFirstResponder()
    }

}

extension AdminViewController: UITableViewDelegate, UITableViewDataSource {
    //=========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AdminCell", forIndexPath: indexPath) as! AdminCell
        cell.backgroundColor = StyleConstants.defaultGrayColor
        let user = filteredUsers[indexPath.row]
        cell.emailLabel.text = user.email
        cell.emailLabel.textColor = UIColor.whiteColor()
        if user.banned {
            cell.statusLabel.text = "BANNED"
            cell.statusLabel.textColor = UIColor.redColor()
        } else if user.locked {
            cell.statusLabel.text = "LOCKED"
            cell.statusLabel.textColor = UIColor.yellowColor()
        } else {
            cell.statusLabel.text = "ACTIVE"
            cell.statusLabel.textColor = UIColor.greenColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let user = filteredUsers[indexPath.row]
        let banAction = UITableViewRowAction(style: .Normal, title: "BAN", handler: {action, indexPath in
            self.root.childByAppendingPath("users/\(user.uid)/banned").setValue("true")
            self.loadUsers(self.searchBar.text!)
        })
        let unbanAction = UITableViewRowAction(style: .Normal, title: "UNBAN", handler: { action, indexPath in
            self.root.childByAppendingPath("users/\(user.uid)/banned").setValue("false")
            self.loadUsers(self.searchBar.text!)
        })
        let lockAction = UITableViewRowAction(style: .Normal, title: "LOCK", handler: {action, indexPath in
            self.root.childByAppendingPath("users/\(user.uid)/locked").setValue("true")
            self.loadUsers(self.searchBar.text!)
        })
        let unlockAction = UITableViewRowAction(style: .Normal, title: "UNLOCK", handler: {action, indexPath in
            self.root.childByAppendingPath("users/\(user.uid)/locked").setValue("false")
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func reloadTable(searchText: String) {
        //filter
        if searchText == "" {
            filteredUsers = users
        } else {
            filteredUsers = users.filter({user in
                return user.email.containsString(searchText)
            })
        }
        self.tableView.reloadData()
    }
    

    
}

extension AdminViewController: UISearchBarDelegate {
    //=========================================================================
    //MARK - SEARCHBAR
    //===========================================================================
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        reloadTable(searchText)
    }
   
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}