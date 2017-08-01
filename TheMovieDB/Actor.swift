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
  var image:UIImage = #imageLiteral(resourceName: "noman")
  var id:Int = 0
  var birthday:String = ""
  var deathday:String?
  var biography:String = ""
  var movies:[Movie] = []
  
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
    
    if let id = json["id"] as? Int {
      self.id = id
    }
  }
  
  func appendData(json:[String:Any]) {
    let fullDateFormatter = DateFormatter()
    fullDateFormatter.dateFormat = "yyyy-MM-dd"
    
    let yearOnlyFormatter = DateFormatter()
    yearOnlyFormatter.dateFormat = "yyyy"
    if let birthday = json["birthday"] as? String {
      self.birthday = String(birthday)
    }
    
    if let deathday = json["deathday"] as? String {
      self.deathday = String(deathday)
    }
    
    if let biography = json["biography"] as? String {
      self.biography = biography
    }
  }
}
