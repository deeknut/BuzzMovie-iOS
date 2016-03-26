//
//  Cells.swift
//  BuzzMovie
//
//  Created by Brian Wang on 2/23/16.
//  Copyright © 2016 DK. All rights reserved.
//

import UIKit

class MovieTableViewCell:UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mpaaRatingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var theaterDateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var consensusTextView: UITextView!
    
    var movie: Movie! {
        didSet {
            mpaaRatingLabel.text = movie.mpaaRating
            titleLabel.text = movie.title
            posterImageView.image = movie.image
            genreLabel.text = ""
            averageRatingLabel.text = String(movie.buzzRating)
            theaterDateLabel.text = "In Theatres: \(movie.theaterReleaseDate)"
            runtimeLabel.text = "Runtime: \(movie.runtime)"
            consensusTextView.text = movie.synopsis
        }
    }
}