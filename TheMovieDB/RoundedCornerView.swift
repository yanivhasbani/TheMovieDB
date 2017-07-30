//
//  RoundedCornerView.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/30/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class RoundedCornerView: UIImageView {

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    self.layer.cornerRadius = rect.height/2
  }
}
