//
//  Genres.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import Foundation
import Alamofire

enum Genres: Int {
  case Adventure = 12
  case Fantasy = 14
  case Animation = 16
  case Drama = 18
  case Horror = 27
  case Action = 28
  case Comedy = 35
  case History = 36
  case Westren = 37
  case Thriller = 53
  case Crime = 80
  case SciFi = 878
  case Mystery = 9648
  case Music = 10402
  case Romance = 10749
  case Family = 10751
  case War = 10752
  case TV = 10770
}

struct Genre: OptionSet {
  let rawValue: Int
  
  static let Adventure  = Genre(rawValue: 12)
  static let Fantasy = Genre(rawValue: 14)
  static let Animation  = Genre(rawValue: 16)
  static let Drama  = Genre(rawValue: 18)
  static let Horror  = Genre(rawValue: 27)
  static let Action  = Genre(rawValue: 28)
  static let Comedy  = Genre(rawValue: 35)
  static let History  = Genre(rawValue: 36)
  static let Westren  = Genre(rawValue: 37)
  static let Thriller  = Genre(rawValue: 53)
  static let Crime  = Genre(rawValue: 80)
  static let SciFi  = Genre(rawValue: 878)
  static let Mystery  = Genre(rawValue: 9648)
  static let Music  = Genre(rawValue: 10402)
  static let Romance  = Genre(rawValue: 10749)
  static let Family  = Genre(rawValue: 10751)
  static let War  = Genre(rawValue: 10752)
  static let TV  = Genre(rawValue: 10770)
  
  static let All: [Genre] = [.Adventure, .Fantasy, .Animation, .Drama, .Horror, .Action, .Comedy, .History,
                            .Westren, .Thriller, .Crime, .SciFi, .Mystery, .Music, .Romance, .Family, .War, .TV]
  
  var description : String {
    let genre = Genres(rawValue: self.rawValue)!
    
    switch genre {
    case .Adventure: return "Adventure"
    case .Fantasy : return "Fantasy"
    case .Animation : return "Animation"
    case .Drama : return "Drama"
    case .Horror : return "Horror"
    case .Action : return "Action"
    case .Comedy : return "Comedy"
    case .History : return "History"
    case .Westren : return "Westren"
    case .Thriller : return "Thriller"
    case .Crime : return "Crime"
    case .SciFi : return "SciFi"
    case .Mystery : return "Mystery"
    case .Music : return "Music"
    case .Romance : return "Romance"
    case .Family : return "Family"
    case .War : return "War"
    case .TV : return "TV"
    }
  }
}
