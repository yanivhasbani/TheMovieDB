//
//  DetailsVC.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/30/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class DetailsVC: UIViewController {
  
  var movie:Movie?
  @IBOutlet var image: UIImageView!
  @IBOutlet var name: UILabel!
  @IBOutlet var year: UILabel!
  @IBOutlet var duration: UILabel!
  @IBOutlet var rate: UILabel!
  @IBOutlet var overview: UITextView!
  @IBOutlet var castCollection: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateUI()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func updateUI() {
    if let movie = movie {
      image.image = movie.bigImage
      name.text = movie.name
      year.text = String(movie.year)
      duration.text = String(movie.duration)
      rate.text = String(movie.rate)
      overview.text = String(movie.overview)
      overview.textAlignment = NSTextAlignment.center
      
      castCollection.delegate = self
      castCollection.dataSource = self
    }
  }
  
}

extension DetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movie!.actors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as? CastCell {
      
      if indexPath.row < movie!.actors.count {
        cell.configure(actor: movie!.actors[indexPath.row])
      }
      
      return cell
    }
    
    return UICollectionViewCell()
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    if indexPath.row < MovieCollection.shared.currentlyShowingMovies.count {
//      let movie = MovieCollection.shared.currentlyShowingMovies[indexPath.row]
//      self.performSegue(withIdentifier: "DetailsVC", sender: movie)
//    }
  }
}
