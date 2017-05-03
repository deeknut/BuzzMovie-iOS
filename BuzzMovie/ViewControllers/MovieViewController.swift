//
//  MovieViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/19/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

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
    
//    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    //===========================================================================
    //MARK - VIEWDIDLOAD/SETUP/ROTATE
    //===========================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        if let image = self.selectedImage {
            backgroundImageView.image = image
        }
        titleLabel.text = movie.title
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        loadUser()
        
        self.setNeedsStatusBarAppearanceUpdate()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func checkLikes(_ closure:@escaping (Bool) -> Void){
        root!.child(byAppendingPath: "users/\(uid)/likes").observeSingleEvent(of: .value, with: { snapshot in
            
            for l in snapshot.children {
                let like = l as! FIRDataSnapshot
                if (like.key == self.movie.RTid) {
                    closure(true)
                }
            }

            closure(false)
        })
    }
    
    func loadUser() {
        root!.child(byAppendingPath: "users/\(uid)").observeSingleEvent(of: .value, with: { snapshot in
            let user = User(snapshot: snapshot)
            self.user = user
        })
    }
    
    func loadUserRecommendation(_ closure:@escaping (Double?, String?) -> Void) {
        root!.child(byAppendingPath: "users/\(uid)/recommendations/\(movie.RTid)").observeSingleEvent(of: .value, with: { snapshot in
            closure(snapshot.value(forKey: "rating") as? Double, snapshot.value(forKey: "recommendation") as? String)
        })
    }
    
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //===========================================================================
    //MARK - SEGUES
    //===========================================================================
    @IBAction func unwindForMovieView(_ unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Exit" {
            self.navigationController?.isNavigationBarHidden = false
        } else if segue.identifier == "RatingSegue" {
            let dest = segue.destination as! MovieRatingViewController
            dest.modalPresentationStyle = .overCurrentContext
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //index == 0 is image
        //index == 1 is actions
        //index == 2 is information
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieImageCell", for: indexPath) as! MovieImageCell
            if let image = selectedImage {
                cell.movieImageView.image = image
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieActionCell", for: indexPath) as! MovieActionCell
            cell.backgroundColor = UIColor.clear
            checkLikes({ isLiked in
                cell.setLike(isLiked)
            })
            
            loadUserRecommendation({ rating, recommendation in
                if let rating = rating, let recommendation = recommendation {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieInfoCell", for: indexPath) as! MovieInfoCell
            cell.backgroundColor = UIColor.clear
            cell.genreLabel.text = selectedGenreString ?? "Unknown Genre"
            cell.mpaaRatingLabel.text = movie.mpaaRating
            cell.synopsisLabel.text = movie.synopsis
            cell.titleLabel.text = movie.title
            movie.loadAvgRating({ avgRating in
                if let avgRating = avgRating {
                    DispatchQueue.main.async(execute: {
                        self.avgRatingLabel.text = "\(avgRating)"
                        cell.avgRatingLabel.text = "\(avgRating)"
                    })
                } else {
                    DispatchQueue.main.async(execute: {
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
    func didLike(_ button: UIButton) {
        root!.child(byAppendingPath: "users/\(uid)/likes/\(movie.RTid)").setValue(movie.title)
    }
    
    func didUnLike(_ button: UIButton) {
        root!.child(byAppendingPath: "users/\(uid)/likes/\(movie.RTid)").removeValue()
    }
    
    func didAddRating(_ button: UIButton) {
        if let _ = self.user {
//            let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MovieRating") as! MovieRatingViewController
//            dest.userRating = self.userRating
//            dest.recommendation = self.recommendation
//            dest.user = self.user
//            dest.movie = self.movie
//            self.presentViewController(dest, animated: true, completion: nil)
            self.performSegue(withIdentifier: "RatingSegue", sender: self)
        }
    }
}
