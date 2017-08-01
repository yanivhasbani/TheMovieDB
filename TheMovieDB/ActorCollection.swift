//
//  ActorCollection.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/31/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit
import Alamofire

class ActorCollection: NSObject {
  var allActors:[Actor] = []
  static let shared = ActorCollection()
  
  func fetchActor(actor:Actor, completion:@escaping ()->()) {
    DispatchQueue.global().async {
      let url = actorURL(actorId: actor.id)
      Alamofire.request(url)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON(completionHandler: { response in
          if let json  = response.result.value as? Dictionary<String, AnyObject> {
            actor.appendData(json: json)
            completion()
          }
        })
    }
  }
}
