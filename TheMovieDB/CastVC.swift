//
//  CastVC.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/30/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class CastVC: UIViewController {
  @IBOutlet var dateOfBirth: UILabel!
  @IBOutlet var movieCollectionView: UICollectionView!
  @IBOutlet var actorImage: UIImageView!
  @IBOutlet var biography: UITextView!
  @IBOutlet var name: UILabel!
  @IBOutlet var dateOfDecease: UILabel!
  @IBOutlet var deceaseStack: UIStackView?
  
  
  @IBOutlet var dobStack: UIStackView!
  var actor:Actor?
  var nextText:String?
  let THRESHOLD = 200
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    name.text = actor?.name
    actorImage.image = actor?.image
    if (actor?.biography.characters.count)! > 0 {
      self.biography.text = actor?.biography
    }
    movieCollectionView.delegate = self
    movieCollectionView.dataSource = self
    biography.delegate = self
    let tap  = UITapGestureRecognizer.init(target: self, action: #selector(CastVC.textViewTapped(_:)))
    biography.addGestureRecognizer(tap)
    ActorCollection.shared.fetchActor(actor:actor!, completion:{
      self.updateUI()
      MovieCollection.shared.downloadMoviesByActor(actor: self.actor!, completion: {
        DispatchQueue.main.async {
          self.movieCollectionView.reloadData()
        }
      })
    })
    // Do any additional setup after loading the view.
  }
  
  func updateUI() {
    if let biography = actor?.biography {
      if biography.characters.count > THRESHOLD {
        self.nextText = biography
        let index = biography.index(actor!.biography.startIndex, offsetBy: 200)
        var trimmedText = actor?.biography.substring(to: index)
        trimmedText?.append("  Read More....")
        self.biography.text = trimmedText
      } else {
        self.biography.text = biography
      }
    }
    
    self.biography.isHidden = false
    if let birthday = actor?.birthday,
      birthday.characters.count > 0 {
      self.dateOfBirth.text = convertDate(date: birthday)
      self.dobStack.isHidden = false
    }
    if let deathDay = actor?.deathday,
      deathDay.characters.count > 0 {
      self.deceaseStack?.isHidden = false
      self.dateOfDecease.text = convertDate(date: deathDay)
    }
    self.view.layoutSubviews()
  }
  
  func textViewTapped(_ sender:UITapGestureRecognizer?) {
    let tmp = self.biography.text
    self.biography.text = self.nextText
    self.nextText = tmp
    self.view.layoutSubviews()
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let detailsVC = segue.destination as? DetailsVC,
      let movie = sender as? Movie {
      detailsVC.movie = movie
    }
  }
  
  @IBAction func homePressed(_ sender: Any) {
    self.navigationController?.popToRootViewController(animated: true)
  }
}


extension CastVC: UICollectionViewDataSource, UICollectionViewDelegate {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return actor!.movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActorMovieCell", for: indexPath) as? ActorMovieCell {
      
      if indexPath.row < 6 {
        if let movie = actor?.movies[indexPath.row],
          movie.image == nil {
          MovieCollection.shared.downloadMovieSmallImage(movie: movie, completion: {
            DispatchQueue.main.async {
              self.movieCollectionView.reloadData()
            }
          })
        }
      }
      
      if indexPath.row < actor!.movies.count {
        cell.configureCell(movie: actor!.movies[indexPath.row])
      }
      
      return cell
    }
    
    return UICollectionViewCell()
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    for cell in movieCollectionView.visibleCells {
      if let index = movieCollectionView.indexPath(for: cell),
        let movie = actor?.movies[index.row] {
        MovieCollection.shared.downloadMovieSmallImage(movie: movie, completion: {
          DispatchQueue.main.async {
            self.movieCollectionView.reloadData()
          }
        })
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let index = movieCollectionView.indexPath(for: cell),
      let movie = actor?.movies[index.row] {
      MovieCollection.shared.downloadMovieSmallImage(movie: movie, completion: {
        DispatchQueue.main.async {
          self.movieCollectionView.reloadData()
        }
      })
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let movie = actor?.movies[indexPath.row]
    self.performSegue(withIdentifier: "DetailsVC", sender: movie)
  }
}

protocol CastUtils {
  func convertDate(date:String) -> String
}

extension CastVC: CastUtils {
  func convertDate(date:String) -> String {
    if date.characters.count > 4 {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = "yyyy-MM-dd"
      let showDate = inputFormatter.date(from: date)
      inputFormatter.dateFormat = "dd-MM-yyy"
      let resultString = inputFormatter.string(from: showDate!)
      
      return resultString
    }
    
    return date
  }
}

extension CastVC: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    print(textView)
    
    return true
  }
}
