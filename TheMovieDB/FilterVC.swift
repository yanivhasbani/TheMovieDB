//
//  FilterVC.swift
//  TheMovieDB
//
//  Created by Yaniv Hasbani on 7/29/17.
//  Copyright © 2017 Yaniv. All rights reserved.
//

import UIKit

enum SegmentType:Int {
  case Genre = 0
  case Year = 1
  case Rate = 2
}

class FilterVC: UIViewController {
  
  @IBOutlet var filterType: UISegmentedControl!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var from: UITextField!
  @IBOutlet var to: UITextField!
  @IBOutlet var picker: UIPickerView!
  @IBOutlet var pickerView: UIView!
  @IBOutlet var fromRate: UITextField!
  @IBOutlet var toRate: UITextField!
  
  
  let yearData = (1900...2017).reversed().map{ return String($0) }
  let rateData = (0...10).reversed().map{ return String($0) }
  let genres = Genre.All
  
  var filters:MovieFilter = MovieFilter(filterType: [], filterValue: [:])
  var currentlyEditTextField: UITextField?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.frame = CGRect(x: 0,
                             y: 0,
                             width: UIScreen.main.bounds.width,
                             height: UIScreen.main.bounds.height * 0.66)
    collectionView.delegate = self
    collectionView.dataSource = self
    
    to.delegate = self
    from.delegate = self
    toRate.delegate = self
    fromRate.delegate = self
    
    picker.delegate = self
    picker.dataSource = self
    
    updateFilters()
  }
  
  func updateFilters() {
    if (filters.filterType.contains(.Year)) {
      if let yearFilters = filters.filterValue[.Year] as? (from:Int, to:Int) {
        if yearFilters.from > Int.min {
          from.text = String(yearFilters.from)
        }
        
        if yearFilters.to < Int.max {
          to.text = String(yearFilters.to)
        }
      }
    }
    
    if (filters.filterType.contains(.Rate)) {
      if let rateFilters = filters.filterValue[.Rate] as? (from:Int, to:Int) {
        if rateFilters.from > Int.min {
          fromRate.text = String(rateFilters.from)
        }
        
        if rateFilters.to < Int.max {
          toRate.text = String(rateFilters.to)
        }
      }
    }
  }
  
  @IBAction func backPressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func updateFilter(textFiled:UITextField) {
    
    var rateRange =  (from:Int.min, to:Int.max)
    var yearRange = (from:Int.min, to:Int.max)
    
    if textFiled == toRate {
      rateRange.to = Int(toRate.text!)!
      filters.filterType.append(.Rate)
      if var rates = filters.filterValue[.Rate] as? (from:Int, to:Int) {
        rates.to = rateRange.to
        filters.filterValue[.Rate] = rates
      } else {
        filters.filterValue[.Rate] = [(from:Int, to:Int)]()
        filters.filterValue[.Rate] = rateRange
      }
      return
    }
    
    if textFiled == fromRate {
      rateRange.from = Int(fromRate.text!)!
      if (!filters.filterType.contains(.Rate)) {
        filters.filterType.append(.Rate)
      }
      if var rates = filters.filterValue[.Rate] as? (from:Int, to:Int) {
        rates.from = rateRange.from
        filters.filterValue[.Rate] = rates
      } else {
        filters.filterValue[.Rate] = [(from:Int, to:Int)]()
        filters.filterValue[.Rate] = rateRange
      }
      return
    }
    
    if textFiled == to {
      yearRange.to = Int(to.text!)!
      filters.filterType.append(.Year)
      if var year = filters.filterValue[.Year] as? (from:Int, to:Int) {
        year.to = yearRange.to
        filters.filterValue[.Year] = year
      } else {
        filters.filterValue[.Year] = [(from:Int, to:Int)]()
        filters.filterValue[.Year] = yearRange
      }
      return
    }
    
    if textFiled == from {
      yearRange.from = Int(from.text!)!
      if (!filters.filterType.contains(.Year)) {
        filters.filterType.append(.Year)
      }
      if var year = filters.filterValue[.Year] as? (from:Int, to:Int) {
        year.from = yearRange.from
        filters.filterValue[.Year] = year
      } else {
        filters.filterValue[.Year] = [(from:Int, to:Int)]()
        filters.filterValue[.Year] = yearRange
      }
      return
    }
  }
  
  
  @IBAction func segmentPressed(_ sender: Any) {
    switch filterType.selectedSegmentIndex {
    case 0:
      self.collectionView.isHidden = false
      self.pickerView.isHidden = true
      break;
    case 1:
      self.collectionView.isHidden = true
      self.picker.reloadAllComponents()
      self.pickerView.isHidden = false
      self.to.isHidden = false
      self.from.isHidden = false
      self.toRate.isHidden = true
      self.fromRate.isHidden = true
      break;
    case 2:
      self.collectionView.isHidden = true
      self.picker.reloadAllComponents()
      self.pickerView.isHidden = false
      self.to.isHidden = true
      self.from.isHidden = true
      self.toRate.isHidden = false
      self.fromRate.isHidden = false
      break;
    default:
      break;
    }
    self.picker.isHidden = true
  }
}

extension FilterVC: UICollectionViewDelegate, UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return genres.count
  }
  
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as? GenreCell {
      if let filteredGenreArray = filters.filterValue[.Genre] as? Array<Genre>,
        filteredGenreArray.contains(genres[indexPath.row]) {
        cell.configure(genre:genres[indexPath.row], checked: true)
      } else {
        cell.configure(genre:genres[indexPath.row], checked: false)
      }
      
      cell.delegate = self
      return cell
    }
    
    return UICollectionViewCell()
  }
  
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
}

extension FilterVC: GenreCellDelegate {
  func genreCellClicked(state: Bool, genre:Genre) {
    if filters.filterValue[.Genre] == nil {
      filters.filterValue[.Genre] = [Genre]()
    }
    
    if !filters.filterType.contains(.Genre) {
      filters.filterType.append(.Genre)
    }
    
    if var filteredGenreArray = filters.filterValue[.Genre] as? Array<Genre> {
      if (state) {
        filteredGenreArray.append(genre)
      } else {
        if let index = filteredGenreArray.index(of: genre) {
          filteredGenreArray.remove(at: index)
        }
      }
      filters.filterValue[.Genre] = filteredGenreArray
      print("Filtered: \(filteredGenreArray.description)")
    }
  }
}

extension FilterVC: UIPickerViewDelegate, UIPickerViewDataSource {
  
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if filterType.selectedSegmentIndex == 1 {
      return yearData.count
    } else if filterType.selectedSegmentIndex == 2 {
      return rateData.count
    }
    
    return 0
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if filterType.selectedSegmentIndex == 1 {
      return yearData[row]
    } else if filterType.selectedSegmentIndex == 2 {
      return rateData[row]
    }
    
    return ""
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let data:String
    if filterType.selectedSegmentIndex == 1 {
      data = yearData[row]
    } else if filterType.selectedSegmentIndex == 2 {
      data = rateData[row]
    } else {
      data = ""
    }
    
    currentlyEditTextField?.text = data
    updateFilter(textFiled: currentlyEditTextField!)
    
    picker.isHidden = true
  }
}

extension FilterVC: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    currentlyEditTextField = textField
    picker.isHidden = false
    return false
  }
}
