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
    var dataReceived:Bool = false
    var dataPending:Bool = false
}

class MovieTableViewCell:GeneralCell{

    @IBOutlet weak var theaterDateLabel: UILabel!
    @IBOutlet weak var consensusTextView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var movie: Movie! {
        didSet {
            //reset
            dataReceived = false
            dataPending = false
            posterImageView.image = UIImage(named: "DefaultPosterImage")
            backgroundImageView.image = nil
            
            theaterDateLabel.text = "In Theatres: \(movie.theaterReleaseDate)"
            consensusTextView.text = movie.synopsis
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            avgRatingLabel.text = String(movie.buzzRating)
            movie.cell = self
            if !dataReceived && !dataPending {
                dataPending = true
                movie.setImageAndGenreForCell()
            }
        }
    }
}

class SearchTableViewCell:GeneralCell {
    
    var movie: Movie! {
        didSet {
            //reset
            dataReceived = false
            dataPending = false
            posterImageView.image = UIImage(named: "DefaultPosterImage")
            
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            genreLabel.text = "No Genre Info Available"
            avgRatingLabel.text = String(movie.buzzRating)
            movie.cell = self
            if !dataReceived && !dataPending {
                dataPending = true
                movie.setImageAndGenreForCell()
            }
        }
    }
}