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
  func finishedLoadingMovies()
  func finishedLoadingSmallImages()
  func finishedLoadingMovieDetails()
}

protocol MovieDetailsDelegate {
  func finishedLoadingMovieDetails()
  func finishedLoadingMovieCast()
  func finishedLoadingCastImages()
}

class MovieCollection {
  static let shared = MovieCollection()
  var moviesNeedSmallImage: Array<Movie> = []
  var moviesNeedDetails: Array<Movie> = []
  
  var allMovies: Array<Movie> = []
  var currentlyShowingMovies: Array<Movie> = []
  
  var movieDelegate: MovieCollectionDelegate?
  var movieDetailsDelegate: MovieDetailsDelegate?
  
  var numOfPages = 1
  var filter: MovieFilter?
  var fetching:Bool = false
  var changed:Bool = false
  var yearsChecked:[Int] = []
  
  private let downloadThreshold = 1500
  
  public func fetch() {
    let url = popularURL.appending("&page=\(self.numOfPages)")
    self.download(url:url, completion: {
      self.currentlyShowingMovies = self.allMovies
      if let filter = self.filter {
        self.filter(filter: filter)
      } else {
        if let movieDelegate = self.movieDelegate {
          movieDelegate.finishedLoadingMovies()
        }
      }
    })
  }
  
  public func fetchMore() {
    DispatchQueue.global().async {
      if let filter = self.filter,
        filter.filterType.count > 0  {
        //If we have any filter, lets try and fetch according to them
        self.smartFetch {
          self.currentlyShowingMovies = self.allMovies
          if let filter = self.filter,
            filter.filterType.count > 0 {
            self.filter(filter: filter)
          } else {
            if let movieDelegate = self.movieDelegate {
              movieDelegate.finishedLoadingMovies()
            }
          }
        }
      } else {
        if self.fetching || self.allMovies.count >= self.downloadThreshold {
          return
        }
        self.numOfPages = self.numOfPages + 1
        let url = popularURL.appending("&page=\(self.numOfPages)")
        //Blindly fetching as there is no filter
        self.download(url:url, completion: {
          self.currentlyShowingMovies = self.allMovies
          if let filter = self.filter {
            self.filter(filter: filter)
          } else {
            if let movieDelegate = self.movieDelegate {
              movieDelegate.finishedLoadingMovies()
            }
          }
        })
      }
    }
  }
  
  func smartFetch(completion:@escaping ()->()) {
    let url = prepareUrlByFilter()
    self.download(url: url, completion: {
      completion()
    })
  }
  
  public func downloadMoviesByActor(actor:Actor, completion:@escaping () -> ()) {
    let url = moviesByActor(actorId: actor.id)
    Alamofire.request(url)
      .validate(statusCode: 200..<300)
      .validate(contentType: ["application/json"])
      .responseJSON(completionHandler: { response in
        if let value = response.result.value as? Dictionary<String, AnyObject> {
          if let results = value["cast"] as? Array<Dictionary<String, AnyObject>> {
            for movie in results {
              if let id  = movie["id"] as? Int {
                let movie = Movie(json:movie)
                let movieInCollection = self.movieExists(movieId:id)
                if movieInCollection == nil {
                  actor.movies.append(movie)
                  self.allMovies.append(movie)
                } else if !actor.movies.contains(movie) {
                  actor.movies.append(movieInCollection!)
                }
                
              }
            }
            completion()
          }
        }
    })
  }
  
  public func downloadMovieSmallImage(movie:Movie, completion:@escaping ()->()) {
    if movie.image != nil {
      return
    }
    self.moviesNeedSmallImage.append(movie)
    DispatchQueue.global().async {
      self.downloadSmallImages {
        completion()
      }
    }
  }
  
  public func downloadMovieDetails(movieId:Int, downloadExtra:Bool) {
    let movie = movieExists(movieId: movieId)
    if movie?.image == nil {
      self.moviesNeedSmallImage.append(movie!)
      self.downloadSmallImages {
        
      }
    }
    self.downloadDetails(movieId: movieId, completion:{
      //Lets download all resources for the first 2 pages(40 movies..)
      if let movieDetailsDelegate = self.movieDetailsDelegate {
        movieDetailsDelegate.finishedLoadingMovieDetails()
      }
      if let movieDelegate = self.movieDelegate {
        movieDelegate.finishedLoadingMovieDetails()
      }
      if downloadExtra {
        DispatchQueue.global().async {
          self.downloadCast(movieId: movieId, completion: {
            if let detailsDelegate = self.movieDetailsDelegate {
              detailsDelegate.finishedLoadingMovieCast()
            }
          })
        }
      }
    })
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
        var allMoviesInGenre:[Movie] = []
        for genre in genres {
          var genreMovies:[Movie] = []
          genreMovies = operatorArray.filter({
            $0.isInGenre(genre: genre) && !allMoviesInGenre.contains($0)
          })
          allMoviesInGenre.append(contentsOf: genreMovies)
        }
        operatorArray = allMoviesInGenre
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
    self.movieDelegate?.finishedLoadingMovies()
  }
  
  private func download(url:String, completion:@escaping ()-> ()) {
    if fetching || self.allMovies.count >= downloadThreshold {
      return
    }
    fetching = true
    
    self.downloadMovies(url:url, completion: {
      completion()
      self.downloadSmallImages {
        if let movieDelegate = self.movieDelegate {
          movieDelegate.finishedLoadingSmallImages()
        }
        //Lets download all resources for the first page(20 movies..)
        for movie in self.moviesNeedDetails {
          self.downloadMovieDetails(movieId: movie.id, downloadExtra:false)
          self.fetching = false
          if let movieDelegate = self.movieDelegate {
            movieDelegate.finishedLoadingMovieDetails()
          }
        }
      }
    })
  }
  
  private func downloadMovies(url:String, completion:@escaping ()->()) {
    self.changed = false
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
                self.allMovies.append(movie)
                if !self.changed {
                  self.changed = true
                }
              }
            }
          }
        }
        if self.changed {
          DispatchQueue.global().async {
            completion()
          }
        } else {
          self.fetching = false
        }
      })
  }
  
  private func downloadSmallImages(completion:@escaping ()->()) {
    let group = DispatchGroup()
    for movie in self.moviesNeedSmallImage {
      group.enter()
      Alamofire.request(smallImageURL + movie.imageURL)
        .responseImage(completionHandler: { response in
          if let image = response.result.value {
            if let index = self.moviesNeedSmallImage.index(of: movie) {
              self.moviesNeedSmallImage.remove(at:index)
              self.moviesNeedDetails.append(movie)
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
  
  private func downloadDetails(movieId:Int, completion:@escaping ()->()) {
    if let movie = movieExists(movieId: movieId) {
      let group = DispatchGroup()
      group.enter()
      Alamofire.request(detailsURL(movieId: movie.id))
        .responseJSON(completionHandler: { response in
          if let details = response.result.value as? Dictionary<String, AnyObject>,
            let tagline = details["tagline"] as? String,
            let duration = details["runtime"] as? Int {
            if let index = self.moviesNeedDetails.index(of: movie) {
              self.moviesNeedDetails.remove(at:index)
            }
            movie.tagline = tagline
            movie.duration = duration
          }
          group.leave()
        })
      group.wait()
      
      DispatchQueue.global().async {
        completion()
      }
    }
  }
  
  private func downloadCast(movieId:Int, completion:@escaping ()->()) {
    if let movie = movieExists(movieId: movieId) {
      Alamofire.request(castURL(movieId:movie.id))
        .responseJSON(completionHandler: { response in
          if let result = response.result.value as? Dictionary<String, AnyObject>,
            let fullCast = result["cast"] as? Array<[String:Any]> {
            for actor in fullCast {
              let actor = Actor(json: actor)
              movie.actors.append(actor)
              DispatchQueue.global().async {
                completion()
              }
            }
          }
        })
    }
  }
  
  public func downloadActorImage(actor:Actor, completion:@escaping ()->()) {
    if actor.image != #imageLiteral(resourceName: "noman") {
      return
    }
    let imageUrl = smallImageURL + actor.imageURL
    Alamofire.request(imageUrl)
      .responseImage(completionHandler: { response in
        if let image = response.result.value {
          actor.image = image
          completion()
        }
      })
  }
  
  private func movieExists(movieId:Int) -> Movie? {
    for movie in allMovies {
      if movie.id == movieId {
        return movie
      }
    }
    
    return nil
  }
  
  private func prepareUrlByFilter() -> String {
    var url = discoverURL
    if self.filter == nil {
      return url
    }
    
    //Genre
    if self.filter!.filterType.contains(.Genre),
      let genres = self.filter!.filterValue[.Genre] as? Array<Genre> {
      url = url.appending("&with_genres=")
      for genre in genres {
        url = url.appending("\(genre.rawValue)|")
      }
      url = url.substring(to: url.index(before: url.endIndex))
    }
    
    if self.filter!.filterType.contains(.Year),
      let years = self.filter!.filterValue[.Year] as? (from:Int, to:Int) {
      if years.to < Int.max {
        if !yearsChecked.contains(years.to) {
          url = url.appending("&primary_release_year=\(years.to)")
          yearsChecked.append(years.to)
        } else {
          if let newYear = getNextYear(years:years, desc:true) {
            yearsChecked.append(newYear - 1)
            url = url.appending("&primary_release_year=\(newYear - 1)")
          }
        }
      } else if years.from > Int.min {
        if !yearsChecked.contains(years.from) {
          url = url.appending("&primary_release_year=\(years.from)")
          yearsChecked.append(years.from)
        } else {
          if let newYear = getNextYear(years:years, desc:false) {
            yearsChecked.append(newYear + 1)
            url = url.appending("&primary_release_year=\(newYear + 1)")
          }
        }
      }
    }
    
    if self.filter!.filterType.contains(.Rate),
      let rates = self.filter!.filterValue[.Rate] as? (from:Int, to:Int) {
      if rates.to < Int.max {
        url = url.appending("&vote_average.lte=\(rates.to)")
      } else if rates.from > Int.min {
        url = url.appending("&vote_average.gte=\(rates.from)")
      }
    }
    
    return url
  }
  
  func getNextYear(years:(from:Int, to:Int), desc:Bool) -> Int? {
    var upperRange:Int, lowerRange:Int
    
    if years.to == Int.max {
      upperRange = 2017
    } else {
      upperRange = years.to
    }
    
    if years.from == Int.min {
      lowerRange = 1900
    } else {
      lowerRange = years.from
    }
    
    if desc {
      return yearsChecked.filter({$0 >=  lowerRange && $0 <= upperRange}).min()
    } else {
      return yearsChecked.filter({$0 >= lowerRange && $0 <= upperRange}).max()
    }
  }
}
