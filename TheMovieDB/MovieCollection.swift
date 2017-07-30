//
//  MovieCollection.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

protocol MovieCollectionDelegate {
  func finishedLoadingData();
}

class MovieCollection {
  static let shared = MovieCollection()
  var allMovies: Array<Movie> = []
  var actorsNeedImage: Array<Actor> = []
  var moviesNeedSmallImage: Array<Movie> = []
  var moviesNeedBigImage: Array<Movie> = []
  var moviesNeedDetails: Array<Movie> = []
  var moviesNeedCast: Array<Movie> = []
  var currentlyShowingMovies: Array<Movie> = []
  var delegate: MovieCollectionDelegate?
  var numOfPages = 1
  var filter: MovieFilter?
  var fetching:Bool = false
  
  private let downloadThreshold = 1500
  
  public func fetch() {
    self.fetchPage(pageId: self.numOfPages, completion: {
      self.currentlyShowingMovies = self.allMovies
      if let filter = self.filter {
        self.filter(filter: filter)
      } else {
        self.delegate?.finishedLoadingData()
      }
    })
  }
  
  public func fetchMore() {
    self.numOfPages = self.numOfPages + 1
    self.fetchPage(pageId: self.numOfPages, completion: {
      self.currentlyShowingMovies = self.allMovies
      if let filter = self.filter {
        self.filter(filter: filter)
      } else {
        self.delegate?.finishedLoadingData()
      }
    })
  }
  
  public func fetchPage(pageId:Int, completion:@escaping ()-> ()) {
    if (fetching || self.allMovies.count >= downloadThreshold) {
      return
    }
    fetching = true
    
    self.downloadMovies(pageId:pageId, completion:{
      self.downloadSmallImages(completion:{
        self.downloadDetails(completion:{
          self.fetching = false
          self.currentlyShowingMovies = self.allMovies
          completion()
          self.downloadCast {
            self.downloadBigImage {
              self.downloadActorImage {
                
              }
            }
          }
        })
      })
    })
  }
  
  
  func downloadMovies(pageId:Int, completion:@escaping ()->()) {
    let url = popularURL.replacingOccurrences(of: "page=", with: "page=\(pageId)")
    Alamofire.request(url)
      .validate(statusCode: 200..<300)
      .validate(contentType: ["application/json"])
      .responseJSON(completionHandler: { response in
        if let value = response.result.value as? Dictionary<String, AnyObject> {
          if let results = value["results"] as? Array<Dictionary<String, AnyObject>> {
            for movie in results {
              let movie = Movie(json:movie)
              if !self.moviesNeedSmallImage.contains(movie),
                !self.allMovies.contains(movie) {
                self.moviesNeedSmallImage.append(movie)
              }
            }
          }
        }
        DispatchQueue.global().async {
          completion()
        }
      })
  }
  
  func downloadSmallImages(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for movie in self.moviesNeedSmallImage {
      group.enter()
      Alamofire.request(smallImageURL + movie.imageURL)
        .responseImage(completionHandler: { response in
          if let image = response.result.value {
            if let index = self.moviesNeedSmallImage.index(of: movie) {
              self.moviesNeedSmallImage.remove(at:index)
              self.moviesNeedDetails.append(movie)
              self.moviesNeedBigImage.append(movie)
            }
            movie.image = image
          }
          group.leave()
        })
    }
    group.wait()
    
    DispatchQueue.global().async {
      completion()
    }
  }
  
  func downloadDetails(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for movie in self.moviesNeedDetails {
      group.enter()
      Alamofire.request(detailsURL(movieId: movie.id))
        .responseJSON(completionHandler: { response in
          if let details = response.result.value as? Dictionary<String, AnyObject>,
            let tagline = details["tagline"] as? String,
            let duration = details["runtime"] as? Int {
            if let index = self.moviesNeedDetails.index(of: movie) {
              self.moviesNeedDetails.remove(at:index)
              self.allMovies.append(movie)
              self.moviesNeedCast.append(movie)
            }
            movie.tagline = tagline
            movie.duration = duration
          }
          group.leave()
        })
    }
    group.wait()
    
    DispatchQueue.global().async {
      completion()
    }
  }
  
  func downloadCast(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for movie in self.moviesNeedCast {
      group.enter()
      Alamofire.request(castURL(movieId:movie.id))
        .responseJSON(completionHandler: { response in
          if let result = response.result.value as? Dictionary<String, AnyObject>,
          let fullCast = result["cast"] as? Array<[String:Any]> {
            for actor in fullCast {
              let actor = Actor(json: actor)
              movie.actors.append(actor)
              self.actorsNeedImage.append(actor)
            }
          }
          group.leave()
        })
    }
    group.wait()
    
    DispatchQueue.global().async {
      completion()
    }
  }
  
  func downloadBigImage(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for movie in self.moviesNeedBigImage {
      group.enter()
      Alamofire.request(bigImageSmallURL + movie.imageURL)
        .responseImage(completionHandler: { response in
          if let image = response.result.value {
            if let index = self.moviesNeedBigImage.index(of: movie) {
              self.moviesNeedBigImage.remove(at:index)
            }
            movie.bigImage = image
          }
          group.leave()
        })
    }
    group.wait()
    
    DispatchQueue.global().async {
      completion()
    }
  }
  
  func downloadActorImage(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for actor in self.actorsNeedImage {
      group.enter()
      Alamofire.request(smallImageURL + actor.imageURL)
        .responseImage(completionHandler: { response in
          if let image = response.result.value {
            if let index = self.actorsNeedImage.index(of: actor) {
              self.actorsNeedImage.remove(at:index)
            }
            actor.image = image
          }
          group.leave()
        })
    }
    group.wait()
    
    DispatchQueue.global().async {
      completion()
    }
  }
  
  public func filter(filter:MovieFilter) {
    var operatorArray:Array<Movie> = allMovies
    if (filter.filterType.contains(.Search)) {
      if let text = filter.filterValue[.Search] as? String{
        if text.characters.count != 0 {
          operatorArray = operatorArray.filter({
            $0.name.contains(text)
          })
        }
      }
    }
    
    if (filter.filterType.contains(.Genre)) {
      if let genres = filter.filterValue[.Genre] as? Array<Genre> {
        for genre in genres {
          operatorArray = operatorArray.filter({
            $0.isInGenre(genre: genre)
          })
        }
      }
    }
    
    if (filter.filterType.contains(.Rate)) {
      if let rates = filter.filterValue[.Rate] as? (from:Int, to:Int) {
        operatorArray = operatorArray.filter({
          $0 >= rates.from && $0 <= rates.to
        })
      }
    }
    
    if (filter.filterType.contains(.Year)) {
      if let yearRange = filter.filterValue[.Year] as? (from:Int, to:Int) {
        operatorArray = operatorArray.filter({
          $0.inYearRange(range: yearRange)
        })
      }
    }
    
    currentlyShowingMovies = operatorArray
    self.filter = filter
    self.delegate?.finishedLoadingData()
  }
}
