//
//  MovieViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/19/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase

class MovieViewController: UIViewController {
    //===========================================================================
    //MARK - VARIABLES
    //===========================================================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var headerView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avgRatingLabel: UILabel!
    
    var movie:Movie!
    var selectedImage:UIImage?
    var selectedGenreString:String?
    
    var userRating:Double?
    var recommendation:String?
    
    var user:User?
    
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/SETUP/ROTATE
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        if let image = self.selectedImage {
            backgroundImageView.image = image
        }
        titleLabel.text = movie.title
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        loadUser()
        
        self.setNeedsStatusBarAppearanceUpdate()

    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func checkLikes(closure:(Bool) -> Void){
        root.childByAppendingPath("users/\(uid)/likes").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let likes = snapshot.children {
                for like in likes {
                    if (like.key == self.movie.RTid) {
                        closure(true)
                    }
                }
            }
            closure(false)
        })
    }
    
    func loadUser() {
        root.childByAppendingPath("users/\(uid)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let user = User(snapshot: snapshot)
            self.user = user
        })
    }
    
    func loadUserRecommendation(closure:(Double?, String?) -> Void) {
        root.childByAppendingPath("users/\(uid)/recommendations/\(movie.RTid)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            closure(snapshot.value["rating"] as? Double, snapshot.value["recommendation"] as? String)
        })
    }
    
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    @IBAction func unwindForMovieView(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Exit" {
            self.navigationController?.navigationBarHidden = false
        } else if segue.identifier == "RatingSegue" {
            let dest = segue.destinationViewController as! MovieRatingViewController
            dest.modalPresentationStyle = .OverCurrentContext
            dest.userRating = self.userRating
            dest.recommendation = self.recommendation
            dest.user = self.user
            dest.movie = self.movie
        }
    }
    

}

extension MovieViewController:UITableViewDelegate, UITableViewDataSource {
    //===========================================================================
    //MARK - TABLEVIEW
    //===========================================================================
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //index == 0 is image
        //index == 1 is actions
        //index == 2 is information
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MovieImageCell", forIndexPath: indexPath) as! MovieImageCell
            if let image = selectedImage {
                cell.movieImageView.image = image
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MovieActionCell", forIndexPath: indexPath) as! MovieActionCell
            cell.backgroundColor = UIColor.clearColor()
            checkLikes({ isLiked in
                cell.setLike(isLiked)
            })
            
            loadUserRecommendation({ rating, recommendation in
                if let rating = rating, recommendation = recommendation {
                    self.userRating = rating
                    self.recommendation = recommendation
                    cell.userRatingLabel.text = "Your rating: \(rating)"
                } else {
                    self.userRating = nil
                    self.recommendation = nil
                    cell.userRatingLabel.text = "Click star button to add rating"
                }
            })
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MovieInfoCell", forIndexPath: indexPath) as! MovieInfoCell
            cell.backgroundColor = UIColor.clearColor()
            cell.genreLabel.text = selectedGenreString ?? "Unknown Genre"
            cell.mpaaRatingLabel.text = movie.mpaaRating
            cell.synopsisLabel.text = movie.synopsis
            cell.titleLabel.text = movie.title
            movie.loadAvgRating({ avgRating in
                if let avgRating = avgRating {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.avgRatingLabel.text = "\(avgRating)"
                        cell.avgRatingLabel.text = "\(avgRating)"
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.avgRatingLabel.text = "TBD"
                        cell.avgRatingLabel.text = "TBD"
                    })
                }
            })
            cell.theaterDateLabel.text = "In Theaters: \(movie.theaterReleaseDate)"
            cell.dvdDateLabel.text = "On DVD: \(movie.dvdReleaseDate)"
            cell.runtimeLabel.text = "Runtime: \(movie.runtime)"
            if movie.criticsRating != -1 {
                cell.criticsRatingLabel.text = "RT Critics Rating: \(movie.criticsRating)%"
            } else {
                cell.criticsRatingLabel.text = "RT Critics Rating: TBD"
            }
            cell.audienceRatingLabel.text = "RT Audience Rating: \(movie.audienceRating)%"
            
            return cell
        }
    }
}

extension MovieViewController: MovieActionDelegate {
    func didLike(button: UIButton) {
        root.childByAppendingPath("users/\(uid)/likes/\(movie.RTid)").setValue(movie.title)
    }
    
    func didUnLike(button: UIButton) {
        root.childByAppendingPath("users/\(uid)/likes/\(movie.RTid)").removeValue()
    }
    
    func didAddRating(button: UIButton) {
        if let _ = self.user {
//            let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MovieRating") as! MovieRatingViewController
//            dest.userRating = self.userRating
//            dest.recommendation = self.recommendation
//            dest.user = self.user
//            dest.movie = self.movie
//            self.presentViewController(dest, animated: true, completion: nil)
            self.performSegueWithIdentifier("RatingSegue", sender: self)
        }
    }
}
