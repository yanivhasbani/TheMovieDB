//
//  CastCell.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/30/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class CastCell: UICollectionViewCell {
    
  @IBOutlet var image: UIImageView!
  @IBOutlet var name: UILabel!
  @IBOutlet var charecter: UILabel!
  
  func configure(actor:Actor) {
    self.image.image = actor.image
    self.name.text = actor.name
    self.charecter.text = actor.characterName
  }
}
