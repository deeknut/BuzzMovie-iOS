//
//  Cells.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GeneralCell:UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!
//    var dataReceived:Bool = false
//    var dataPending:Bool = false
}

class MovieTableViewCell:GeneralCell{

    @IBOutlet weak var theaterDateLabel: UILabel!
    @IBOutlet weak var consensusTextView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var movie: Movie! {
        didSet {
//            print(movie.originalImage)
            //reset
//            dataReceived = false
//            dataPending = false
            posterImageView.image = UIImage(named: "DefaultPosterImage")
            backgroundImageView.image = nil
            
            theaterDateLabel.text = "In Theatres: \(movie.theaterReleaseDate)"
            consensusTextView.text = movie.synopsis
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            avgRatingLabel.text = "TBD"
            movie.loadAvgRating({ avgrating in
                if let avgrating = avgrating {
                    DispatchQueue.main.async(execute: {
                        self.avgRatingLabel.text = "\(avgrating)"
                    })
                }
            })
            movie.cell = self
//            if !dataReceived && !dataPending {
//                dataPending = true
            movie.setImageAndGenreForCell()
//            }
        }
    }
    
//    func setMovie(movie:Movie) {
//        self.movie = movie
//    }
}

class SearchTableViewCell:GeneralCell {
    
    var movie: Movie! {
        didSet {
            //reset
//            dataReceived = false
//            dataPending = false
            posterImageView.image = UIImage(named: "DefaultPosterImage")
            
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            avgRatingLabel.text = "TBD"
            movie.loadAvgRating({ avgrating in
                if let avgrating = avgrating {
                    DispatchQueue.main.async(execute: {
                        self.avgRatingLabel.text = "\(avgrating)"
                    })
                }
            })
            movie.cell = self
//            if !dataReceived && !dataPending {
//                dataPending = true
            movie.setImageAndGenreForCell()
//            }
        }
    }
}

class MovieImageCell:UITableViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    
}

protocol MovieActionDelegate {
    func didLike(_ button:UIButton)
    func didUnLike(_ button:UIButton)
    func didAddRating(_ button:UIButton)
}

class MovieActionCell:UITableViewCell {
    var delegate:MovieActionDelegate?
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var addRatingButton: UIButton!
    @IBOutlet weak var userRatingLabel: UILabel!
    
    override func awakeFromNib() {
        likeButton.addTarget(self, action: #selector(MovieActionCell.like), for: .touchUpInside)
    }
    
    func like() {
        setLike(true)
        delegate?.didLike(likeButton)
    }
    
    func unlike() {
        setLike(false)
        delegate?.didUnLike(likeButton)
    }
    
    func setLike(_ like:Bool) {
        if like {
            likeButton.removeTarget(self, action: #selector(MovieActionCell.like), for: .touchUpInside)
            likeButton.addTarget(self, action: #selector(MovieActionCell.unlike), for: .touchUpInside)
            DispatchQueue.main.async(execute: {
                self.likeButton.setBackgroundImage(UIImage(named: "Like"), for: UIControlState())
            })
        } else {
            likeButton.removeTarget(self, action: #selector(MovieActionCell.unlike), for: .touchUpInside)
            likeButton.addTarget(self, action: #selector(MovieActionCell.like), for: .touchUpInside)
            DispatchQueue.main.async(execute: {
                self.likeButton.setBackgroundImage(UIImage(named: "NotLike"), for: UIControlState())
            })
        }
    }
    
    @IBAction func addRating(_ sender: UIButton) {
        delegate?.didAddRating(likeButton)
    }
    
}

class MovieInfoCell:UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avgRatingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var theaterDateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var dvdDateLabel: UILabel!
    @IBOutlet weak var criticsRatingLabel: UILabel!
    @IBOutlet weak var audienceRatingLabel: UILabel!
    
}

class AdminCell:UITableViewCell {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
}
