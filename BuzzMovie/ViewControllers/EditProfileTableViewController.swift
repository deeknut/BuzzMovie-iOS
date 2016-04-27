//
//  EditProfileTableViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/26/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase

class EditProfileTableViewController: UITableViewController {
    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var interestsTextView: UITextView!

    var user:User!
    
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    //===========================================================================
    //MARK - VIEWDIDLOAD/SETUP
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        loadInfo()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadInfo() {
        if let user = user {
            majorTextField.text = user.major
            interestsTextView.text = user.interests
        }
    }
    
    //===========================================================================
    //MARK - STATUS BAR
    //===========================================================================
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Save" {
            //save the shit
            let uidRoot = root.childByAppendingPath("users/\(uid)")
            uidRoot.childByAppendingPath("major").setValue(majorTextField.text)
            uidRoot.childByAppendingPath("interests").setValue(interestsTextView.text)
        }
    }
    

}
