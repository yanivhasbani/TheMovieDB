//
//  ActorMovieCell.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/31/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class ActorMovieCell: UICollectionViewCell {
    
  @IBOutlet var movieImage: UIImageView!
  @IBOutlet var movieName: UILabel!
  
  func configureCell(movie:Movie) {
    self.movieImage.image = movie.image
    self.movieName.text = movie.name
  }
}
