//
//  MovieRatingViewController.swift
//  BuzzMovie
//
//  Created by Brian Wang on 4/27/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class MovieRatingViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var recTextView: UITextView!
    @IBOutlet weak var containerViewConstraint: NSLayoutConstraint!
    
    var userRating:Double?
    var recommendation:String?
    var user:User!
    
    var movie:Movie!
    
    var root = Firebase(url: "https://deeknutssquad.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recTextView.delegate = self
        titleLabel.text = movie.title
        
        if let userRating = userRating {
            cosmosView.rating = userRating
            ratingLabel.text = "\(userRating)"
        } else {
            cosmosView.rating = 0
            ratingLabel.text = ""
        }
        
        if let recommendation = recommendation {
            recTextView.text = recommendation
            recTextView.textColor = UIColor.whiteColor()
        } else {
            recTextView.text = "Write recommendation here..."
            recTextView.textColor = UIColor.lightGrayColor()
        }
        
        cosmosView.settings.fillMode = .Half
        cosmosView.didFinishTouchingCosmos = { value in
            self.ratingLabel.text = "\(value)"
        }
        
        cosmosView.didTouchCosmos = { value in
            self.ratingLabel.text = "\(value)"
        }
        
        self.view.backgroundColor = UIColor.clearColor()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MovieRatingViewController.keyboardDidAppear(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MovieRatingViewController.keyboardDidDisappear), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardDidAppear(notification: NSNotification) {
        if let userInfo = notification.userInfo, frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue {
            let height = frame().height
            let constant = 0 - (height / (is4S() ? 2.5 : 3))
            
            if constant == containerViewConstraint.constant { return
            }
            
            UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                    self.containerViewConstraint.constant = constant
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func keyboardDidDisappear() {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
                self.containerViewConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!.locationInView(self.view)
        if !CGRectContainsPoint(recTextView.frame, touch) {
            recTextView.resignFirstResponder()
        }
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
        recTextView.resignFirstResponder()
    }
    
    @IBAction func save() {
        saveRating()
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.performSegueWithIdentifier("Exit", sender: self)
    }
    func saveRating() {
        var parameters:[String:AnyObject] = [
            "rtid": movie.RTid,
            "uid": uid,
            "rating": cosmosView.rating,
            "major": user.major,
            "recommendation": recTextView.text
        ]
        if recTextView.text == "Write recommendation here..." {
            parameters["recommendation"] = ""
        }
        root.childByAppendingPath("users/\(uid)/recommendations/\(movie.RTid)").setValue(parameters)
        
        let movieRoot = root.childByAppendingPath("movies/\(movie.RTid)")
        movieRoot.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let totalRating = snapshot.value["totalrating"] as? Double, numRatings = snapshot.value["numratings"] as? Double {
                if let userRating = self.userRating {
                    //preexisting rating
                    let avgRating = (totalRating - userRating + self.cosmosView.rating) / (numRatings)
                    let dict = [
                        "avgrating": avgRating,
                        "totalrating": totalRating - userRating + self.cosmosView.rating,
                        "numratings": numRatings
                    ]
                    movieRoot.setValue(dict)
                } else {
                    //new rating
                    let avgRating = (totalRating + self.cosmosView.rating) / (numRatings + 1)
                    let dict = [
                        "avgrating": avgRating,
                        "totalrating": totalRating + self.cosmosView.rating,
                        "numratings": numRatings + 1
                    ]
                    movieRoot.setValue(dict)
                }
            } else {
                //first and new rating
                let dict = [
                    "avgrating": self.cosmosView.rating,
                    "totalrating": self.cosmosView.rating,
                    "numratings": 1
                ]
                movieRoot.setValue(dict)
            }
            self.performSegueWithIdentifier("Exit", sender: self)
        })
        
    }

}

extension MovieRatingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Write recommendation here..." {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write recommendation here..."
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}
