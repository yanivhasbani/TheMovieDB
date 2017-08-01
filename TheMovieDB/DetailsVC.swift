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
  
  @IBOutlet var durationStack: UIStackView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateUI()
    // Do any additional setup after loading the view.
  }
  
  func updateUI() {
    if let movie = movie {
      image.image = movie.image
      name.text = movie.name
      year.text = String(movie.year)
      if let duration = movie.duration {
        self.duration.text = String(duration)
        self.durationStack.isHidden = false
      }
      rate.text = String(movie.rate)
      overview.text = String(movie.overview)
      overview.textAlignment = NSTextAlignment.center
      overview.isScrollEnabled = true
      
      castCollection.delegate = self
      castCollection.dataSource = self
      
      MovieCollection.shared.movieDetailsDelegate = self
      DispatchQueue.global().async {
        MovieCollection.shared.downloadMovieDetails(movieId:movie.id, downloadExtra:true)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let castVC = segue.destination as? CastVC,
      let actor = sender as? Actor {
      castVC.actor = actor
    }
  }
  
  @IBAction func homePressed(_ sender: Any) {
    self.navigationController?.popToRootViewController(animated: true)
  }
  
}

extension DetailsVC: MovieDetailsDelegate {
  func finishedLoadingMovieCast() {
    DispatchQueue.main.async {
      self.castCollection.reloadData()
      self.view.layoutIfNeeded()
    }
  }
  
  func finishedLoadingCastImages() {
    DispatchQueue.main.async {
      self.castCollection.reloadData()
      self.view.layoutIfNeeded()
    }
  }
  
  func finishedLoadingMovieDetails() {
    DispatchQueue.main.async {
      if let duration = self.movie?.duration {
        self.duration.text = String(duration)
        self.durationStack.isHidden = false
      }
      self.view.layoutIfNeeded()
    }
  }
}

extension DetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return movie!.actors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as? CastCell {
      
      if indexPath.row < 6 {
        if let actor = movie?.actors[indexPath.row] {
          MovieCollection.shared.downloadActorImage(actor:actor, completion: {
            DispatchQueue.main.async {
              self.castCollection.reloadData()
            }
          })
        }
      }
      
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
    let actor = movie!.actors[indexPath.row]
    self.performSegue(withIdentifier: "CastVC", sender: actor)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    for cell in castCollection.visibleCells {
      if let index = castCollection.indexPath(for: cell),
        let actor = movie?.actors[index.row] {
        MovieCollection.shared.downloadActorImage(actor: actor, completion: {
          self.castCollection.reloadData()
        })
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let index = castCollection.indexPath(for: cell),
      let actor = movie?.actors[index.row] {
      MovieCollection.shared.downloadActorImage(actor:actor, completion: {
        self.castCollection.reloadData()
      })
    }
  }
}
