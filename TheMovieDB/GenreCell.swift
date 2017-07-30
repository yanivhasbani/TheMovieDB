//
//  GenreCell.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/29/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

protocol GenreCellDelegate {
  func genreCellClicked(state:Bool, genre:Genre);
}

class GenreCell: UICollectionViewCell {
  
  @IBOutlet var genre: UILabel!
  @IBOutlet var checkBox: UIButton!
  
  var checked: Bool = false
  var genreModel: Genre?
  var delegate: GenreCellDelegate?
  
  func configure(genre:Genre, checked:Bool) {
    self.genreModel = genre
    self.genre.text = genre.description
    self.checked = checked
    
    checkBox.setBackgroundImage(#imageLiteral(resourceName: "unchecked"), for: UIControlState.normal)
    checkBox.setBackgroundImage(#imageLiteral(resourceName: "checked"), for: UIControlState.selected)
    checkBox.setBackgroundImage(#imageLiteral(resourceName: "checked"), for: UIControlState.highlighted)
    checkBox.adjustsImageWhenHighlighted = true
    
    checkBox.isSelected = checked
  }
  
  @IBAction func checkBoxPressed(_ sender: UIButton) {
    checked = !checked
    sender.isSelected = checked
    self.delegate?.genreCellClicked(state: checked, genre: genreModel!)
  }
}
