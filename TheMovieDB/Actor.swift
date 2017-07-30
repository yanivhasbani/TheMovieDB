//
//  Actor.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/30/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

func ==(lhs: Actor, rhs: Actor) -> Bool {
  return lhs.name == rhs.name
}

class Actor: Equatable {
  var name:String = ""
  var imageURL:String = ""
  var characterName:String = ""
  var image:UIImage = UIImage()
  
  func description() -> String {
    return "name=\(name)\ncharecter=\(characterName)\n"
  }
  
  init(json:[String:Any]) {
    if let name = json["name"] as? String {
      self.name = name
    }
    
    if let characterName = json["character"] as? String {
      self.characterName = characterName
    }
    
    if let imageURL = json["profile_path"] as? String {
      self.imageURL = imageURL
    }
  }
}
