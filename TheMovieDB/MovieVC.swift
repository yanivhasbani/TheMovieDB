//
//  MovieVC.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/28/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

class MovieVC: UIViewController {
  
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var filterStack: UIStackView!
  @IBOutlet var yearFilter: UITextField!
  @IBOutlet var genreFilter: UITextField!
  @IBOutlet var rateFilter: UITextField!
  @IBOutlet var searchBar: UISearchBar!
  
  var filters = MovieFilter(filterType: [], filterValue: [:])
  fileprivate var loaded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchBar.delegate = self
    searchBar.returnKeyType = UIReturnKeyType.done
    for v in searchBar.subviews[0].subviews
    {
      if let textField = v as? UITextField {
        textField.enablesReturnKeyAutomatically = false
        break;
      }
    }
    

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    collectionView.delegate = self
    collectionView.dataSource = self
    genreFilter.allowsEditingTextAttributes = false
    genreFilter.delegate = self
    yearFilter.allowsEditingTextAttributes = false
    yearFilter.delegate = self
    rateFilter.allowsEditingTextAttributes = false
    rateFilter.delegate = self
    MovieCollection.shared.movieDelegate = self
    
    
    MovieCollection.shared.fetch()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if filters.filterType.count > 0 {
      displayFilters(filter: filters)
      MovieCollection.shared.filter(filter: filters)
    }
  }
  
  private func displayFilters(filter:MovieFilter) {
    var unhide: Bool = false
    if (filter.filterType.contains(.Genre)) {
      if let genres = filter.filterValue[.Genre] as? Array<Genre> {
        genreFilter.text = ""
        for genre in genres {
          genreFilter.text = genreFilter.text?.appending(genre.description)
          if (genres.last != genre) {
              genreFilter.text = genreFilter.text?.appending(", ")
          }
        }
        genreFilter.isHidden = false
        unhide = true
      }
    }
    
    if (filter.filterType.contains(.Rate)) {
      if let rates = filter.filterValue[.Rate] as? (from:Int, to:Int) {
        
        if (rates.from > Int.min && rates.to < Int.max) {
            rateFilter.text = "\(rates.from) < Rate < \(rates.to)"
        } else if (rates.from > Int.min) {
          rateFilter.text = "\(rates.from) < Rate"
        } else {
          rateFilter.text = "Rate < \(rates.to)"
        }
        
        rateFilter.isHidden = false
        unhide = true
      }
    }
    

    
    if (filter.filterType.contains(.Year)) {
      if let years = filter.filterValue[.Year] as? (from:Int, to:Int) {
        
        if (years.from > Int.min && years.to < Int.max) {
          yearFilter.text = "Years \(years.from)-\(years.to)"
        } else if (years.from > Int.min) {
          yearFilter.text = "From year \(years.from)"
        } else {
          yearFilter.text = "Up to year \(years.to)"
        }
        yearFilter.isHidden = false
        unhide = true
      }
    }
    
    if (unhide) {
      self.filterStack.isHidden = false
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let filterVC = segue.destination as? FilterVC,
      let filters = sender as? MovieFilter {
      filterVC.filters = filters
    }
    
    if let detailsVC = segue.destination as? DetailsVC,
      let movie = sender as? Movie {
      detailsVC.movie = movie
    }
  }
  
  @IBAction func filterPressed(_ sender: Any) {
    self.performSegue(withIdentifier: "FilterVC", sender: self.filters)
  }
}

//MARK:UISearchBarDelegate
extension MovieVC: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if (!filters.filterType.contains(.Search)) {
      filters.filterType.append(.Search)
    }
    filters.filterValue[.Search] = searchText
    MovieCollection.shared.filter(filter: filters)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    let index = filters.filterType.index(of: .Search)
    filters.filterType.remove(at: index!)
    filters.filterValue[.Search] = nil
    MovieCollection.shared.filter(filter: filters)
  }
}

//MARK:UITextFieldDelegate
extension MovieVC: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return false
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    var filterType:MyFilterTypes
    if (textField == genreFilter) {
      filterType = .Genre
      genreFilter.isHidden = true
    } else if (textField == rateFilter) {
      filterType = .Rate
      rateFilter.isHidden = true
    } else if (textField == yearFilter) {
      filterType = .Year
      yearFilter.isHidden = true
    } else {
      searchBar.resignFirstResponder()
      filterType = .Search
    }
    
    filters.filterValue[filterType] = nil;
    if let filterIndex = filters.filterType.index(of: filterType) {
      filters.filterType.remove(at: filterIndex)
    }
    MovieCollection.shared.filter(filter: filters)
    return true
  }
}

//MARK:MovieCollectionDelegate
extension MovieVC: MovieCollectionDelegate {
  func reloadCollectionview() {
    if !self.loaded {
      self.loaded = true
    }
    
    if !self.filterStack.isHidden &&
      self.filters.filterType.count == 0 ||
      (self.filters.filterType.count == 1 && self.filters.filterType.contains(.Search)) {
      self.filterStack.isHidden = true
    }
    self.collectionView.reloadData()
  }
  
  func finishedLoadingMovies() {
    DispatchQueue.main.async {
      self.reloadCollectionview()
    }
  }
  
  func finishedLoadingMovieDetails() {
    DispatchQueue.main.async {
      self.reloadCollectionview()
    }
  }
  
  func finishedLoadingSmallImages() {
    DispatchQueue.main.async {
      self.reloadCollectionview()
    }
  }
}

//MARK:UICollectionViewDataSource, UICollectionViewDelegate
extension MovieVC: UICollectionViewDelegate {
  
}

extension MovieVC: UICollectionViewDataSource  {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if notEnoughData() {
      MovieCollection.shared.fetchMore()
    }
    return MovieCollection.shared.currentlyShowingMovies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell {
      //FetchMore in case of scrolling to end
      if lastCellOnScroll(indexPath: indexPath) {
        MovieCollection.shared.fetchMore()
      }
      
      if (indexPath.row < MovieCollection.shared.currentlyShowingMovies.count) {
        cell.configure(movie: MovieCollection.shared.currentlyShowingMovies[indexPath.row])
      }
      
      return cell
    }
    
    return UICollectionViewCell()
  }
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.row < MovieCollection.shared.currentlyShowingMovies.count {
      let movie = MovieCollection.shared.currentlyShowingMovies[indexPath.row]
      self.performSegue(withIdentifier: "DetailsVC", sender: movie)
    }
  }
  
  func notEnoughData() -> Bool {
    return MovieCollection.shared.currentlyShowingMovies.count == 0
  }
  
  func lastCellOnScroll(indexPath:IndexPath) -> Bool {
    return indexPath.row == MovieCollection.shared.currentlyShowingMovies.count - 1
  }
}
