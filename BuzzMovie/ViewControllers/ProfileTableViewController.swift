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
//    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
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
            label?.textColor = UIColor.white
        }
        loadUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //===========================================================================
    //MARK - STATUS BAR
    //===========================================================================
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    func loadUser() {
        root?.child(byAppendingPath: "users/\(uid)").observeSingleEvent(of: .value, with: { snapshot in
            self.user = User(snapshot: snapshot as FIRDataSnapshot)
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
    @IBAction func prepareToLogout(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.performSegue(withIdentifier: "Exit", sender: self)
        })
        let actionNo = UIAlertAction(title: "No", style: .default, handler: nil)
        alertController.addAction(actionYes)
        alertController.addAction(actionNo)
        
        self.present(alertController, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let dest = segue.destination as! EditProfileTableViewController
            dest.user = self.user
        }
    }
    
    @IBAction func unwindToProfile(_ unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        if unwindSegue.identifier == "Save" {
            loadUser()
        }
    }

}

extension ProfileTableViewController {
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "EditCell" {
            if let user = user {
                self.performSegue(withIdentifier: "EditSegue", sender: self)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let user = user {
            return user.email
        } else {
            return " "
        }
    }
}
