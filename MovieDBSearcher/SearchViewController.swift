//
//  ViewController.swift
//  MovieDBSearcher
//
//  Created by Chen Shi on 4/13/17.
//  Copyright © 2017 Chen Shi. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import Toast_Swift

class SearchViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var btnScrollToTop: UIButton!
    let viewModel = SearchViewModel()
    
  let searchController = UISearchController(searchResultsController: nil)
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView();
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func configureView() {
    searchController.searchBar.delegate = self
    searchController.searchBar.placeholder = "Find movies by title"
    searchController.searchBar.tintColor = UIColor.white
    definesPresentationContext = true
    searchController.dimsBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar
  }
  
  @IBAction func scrollToTop(_ sender: Any) {
    tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
  }
  
  // MARK: - PrepareForSegue
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "DetailsSegue" {
      let vc = segue.destination as! DetailsViewController
      vc.movie = viewModel.movies[(tableView.indexPathForSelectedRow?.row)!]
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
  
  // MARK: - UISearchBar Delegate
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    viewModel.load(isNewSearch: true, url: searchController.searchBar.text!)
  }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // check if lazy loading is needed
        if indexPath.row + 10 > viewModel.movies.count{
            viewModel.load(isNewSearch: false, url: searchController.searchBar.text!)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        cell.display(movie: viewModel.movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailsSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // display ScrollToTop button when tableview scrolls down
        btnScrollToTop.isHidden = scrollView.contentOffset.y > -tableView.contentInset.top ? false : true
        
        // load more when tableview reaches the bottom
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom for lazy loading, together with cellForRowAt's lazy loading
        if maximumOffset - currentOffset <= 10.0 {
            viewModel.load(isNewSearch: false, url: searchController.searchBar.text!)
        }
    }
    
}

