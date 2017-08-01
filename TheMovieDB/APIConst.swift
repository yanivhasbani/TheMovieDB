//
//  APIConst.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import Foundation

let apiKey = "5fa91f4d299a99ecc758dfeb22e26c10"
let language = "en-US"
let popularURL = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=\(language)"
let smallImageURL = "https://image.tmdb.org/t/p/w150"
let discoverURL = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)"

func detailsURL(movieId:Int) -> String{
    return "https://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)&language=\(language)"
}

func castURL(movieId:Int) -> String {
  return "https://api.themoviedb.org/3/movie/\(movieId)/credits?api_key=\(apiKey)"
}

func actorURL(actorId: Int) -> String {
  return "https://api.themoviedb.org/3/person/\(actorId)?api_key=\(apiKey)&language=\(language)"
}

func moviesByActor(actorId:Int) -> String {
  return "https://api.themoviedb.org/3/person/\(actorId)/movie_credits?api_key=\(apiKey)&language=\(language)"
}




