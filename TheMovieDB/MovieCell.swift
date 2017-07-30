//
//  MovieCell.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
  
  @IBOutlet var movieImage: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var yearLabel: UILabel!
  @IBOutlet var rateLabel: UILabel!
  @IBOutlet var tagline: UITextView!
  
  func configure(movie:Movie) {
    self.nameLabel.text = movie.name
    self.yearLabel.text = String(movie.year)
    self.rateLabel.text = String(round(movie.rate * 10) / 10)
    self.tagline.text = movie.tagline
    self.movieImage.image = movie.image
  }
  
}
