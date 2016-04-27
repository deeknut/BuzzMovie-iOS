//
//  MovieViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/19/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit

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
    
    
    //===========================================================================
    //MARK - VIEWDIDLOAD
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        if let image = self.selectedImage {
            backgroundImageView.image = image
        }
        titleLabel.text = movie.title
        avgRatingLabel.text = String(movie.buzzRating)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        self.setNeedsStatusBarAppearanceUpdate()

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
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        self.navigationController?.navigationBarHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MovieInfoCell", forIndexPath: indexPath) as! MovieInfoCell
            cell.backgroundColor = UIColor.clearColor()
            cell.genreLabel.text = selectedGenreString ?? "Unknown Genre"
            cell.mpaaRatingLabel.text = movie.mpaaRating
            cell.synopsisLabel.text = movie.synopsis
            cell.titleLabel.text = movie.title
            cell.avgRatingLabel.text = "\(movie.buzzRating)"
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
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            if let image = selectedImage {
//                return self.view.frame.width * image.size.height / image.size.width * 0.75
//            }
//            return 0
//        } else if indexPath.row == 1 {
//            return 50
//        } else {
//            return 750
//        }
//    }
}