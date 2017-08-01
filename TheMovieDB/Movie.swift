//
//  Movie.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

func >=(lhs: Movie, rhs: Int) -> Bool {
  return lhs.rate >= Float(rhs)
}

func <=(lhs: Movie, rhs: Int) -> Bool {
  return lhs.rate <= Float(rhs)
}

func ==(lhs: Movie, rhs: Movie) -> Bool {
  return lhs.name == rhs.name
}

class Movie: Equatable {
  var rate: Float = 0.0
  var year: Int = 0
  var tagline: String = ""
  var imageURL : String = ""
  var image: UIImage?
  var bigImage: UIImage = UIImage()
  var genres: Array<Genre> = []
  var name:String = ""
  var id:Int = -1
  var overview:String = ""
  var actors:[Actor] = []
  var duration:Int?
  
  public func inYearRange(range:(from: Int, to: Int)) -> Bool {
    return year >= range.from && year <= range.to
  }
  
  public func isInGenre(genre:Genre) -> Bool {
    return genres.contains(genre)
  }
  
  init(json:Dictionary<String, AnyObject>) {
    if let rate = json["vote_average"] as? Float {
      self.rate = rate
    }
    
//    if let popularity = json["popularity"] as? Float {
//      self.rate = popularity
//    }
    
    if let fullDate = json["release_date"] as? String,
      fullDate.characters.count > 5 {
      let index = fullDate.index(fullDate.startIndex, offsetBy: 4)
      self.year = Int(fullDate.substring(to:index))!
    }
    
    if let overview = json["overview"] as? String {
      self.overview = overview
    }
    
    if let imageURL = json["poster_path"] as? String {
      self.imageURL = imageURL
    }
    
    if let genreIds = json["genre_ids"] as? Array<Int> {
      for genreInt in genreIds {
        self.genres.append(Genre(rawValue: genreInt))
      }
    }
    
    if let name = json["original_title"] as? String {
      self.name = name
    }
    
    if let id = json["id"] as? Int {
      self.id = id
    }
  }
}
