//
//  MovieFilter.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/29/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import Foundation

struct MyFilterTypes : OptionSet, Hashable {
  public var hashValue: Int { get{
      return self.rawValue
  }}
  
  let rawValue: Int
  
  static let Search  = MyFilterTypes(rawValue: 0)
  static let Year = MyFilterTypes(rawValue: 1 << 0)
  static let Genre  = MyFilterTypes(rawValue: 1 << 1)
  static let Rate  = MyFilterTypes(rawValue: 1 << 2)
}

class MovieFilter {
  var filterType:[MyFilterTypes]
  var filterValue:[MyFilterTypes: Any]
  
  init(filterType:[MyFilterTypes], filterValue:Dictionary<MyFilterTypes, Any>) {
    self.filterType = filterType
    self.filterValue = filterValue
  }
}


