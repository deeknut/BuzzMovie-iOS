//
//  ProfileTableViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/26/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class ProfileTableViewController: UITableViewController {
    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var recLabel: UILabel!
    
    @IBOutlet weak var staticDateLabel: UILabel!
    @IBOutlet weak var staticMajorLabel: UILabel!
    @IBOutlet weak var staticInterestsLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    
    @IBOutlet weak var likeBackgroundImageView: UIImageView!
    @IBOutlet weak var likeImage1: UIImageView!
    @IBOutlet weak var likeImage2: UIImageView!
    @IBOutlet weak var likeImage3: UIImageView!
    @IBOutlet weak var recBackgroundImageView: UIImageView!
    @IBOutlet weak var recImage1: UIImageView!
    @IBOutlet weak var recImage2: UIImageView!
    @IBOutlet weak var recImage3: UIImageView!
    
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    var user:User! {
        didSet {
            loadInfo()
            tableView.reloadData()
        }
    }
    
    //===========================================================================
    //MARK - VIEWDIDLOAD
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        let labels = [likesLabel, recLabel, staticDateLabel, staticMajorLabel, staticInterestsLabel, dateLabel, majorLabel, interestsLabel]
        for label in labels {
            label.textColor = UIColor.whiteColor()
        }
        loadUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func loadUser() {
        root.childByAppendingPath("users/\(uid)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.user = User(snapshot: snapshot)
        })
    }
    
    func loadInfo() {
        dateLabel.text = user.registerDate
        majorLabel.text = user.major
        interestsLabel.text = user.interests
    }
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue" {
            let dest = segue.destinationViewController as! EditProfileTableViewController
            dest.user = self.user
        }
    }
    
    @IBAction func unwindToProfile(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier == "Save" {
            loadUser()
        }
    }

}

extension ProfileTableViewController {
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "EditCell" {
            if let user = user {
                self.performSegueWithIdentifier("EditSegue", sender: self)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let user = user {
            return user.email
        } else {
            return " "
        }
    }
}