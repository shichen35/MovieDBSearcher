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

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnScrollToTop: UIButton!
    let searchController = UISearchController(searchResultsController: nil)
    
    var movieArray = [MovieObject]()
    var queryStr = ""
    var totalResults = 0
    var totalPages = 0
    var loadedPages = 0
    var isLoading = false
    
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
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func load(isNewSearch: Bool) {
        if isLoading {
            return
        }
        if isNewSearch {
            movieArray.removeAll()
            tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
            tableView.reloadData()
            loadedPages = 0
            totalPages = 0
            totalResults = 0
            queryStr = searchController.searchBar.text!
        }else if loadedPages >= totalPages || queryStr == "" {
            return
        }
        queryStr = queryStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = "https://api.themoviedb.org/3/search/movie?api_key=cd1b2e1f7ac5a8c23c78a55c28747049&query=\(queryStr)&page=\(String(loadedPages + 1))"
        
        isLoading = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url, method: .get, parameters: nil).responseJSON { response in
            self.isLoading = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard response.result.isSuccess else {
                print("Error while fetching data.")
                self.view.makeToast("Error while fetching data.")
                return
            }
            
            guard let JSON = response.result.value as? [String: Any],
                let total_results = JSON["total_results"] as? Int,
                let total_pages = JSON["total_pages"] as? Int else {
                    print("Malformed data received from MovieDBAPI service")
                    self.view.makeToast("Malformed data received from MovieDBAPI service")
                    return
            }
            
            self.totalPages = total_pages
            self.totalResults = total_results
            self.loadedPages += 1
            
            if isNewSearch {
                self.view.makeToast("\(total_results) results")
            }
            
            let movieArr = JSON["results"] as! [[String: Any]]
            for movie in movieArr {
                guard let newMovie = MovieObject.init(dict: movie) else {
                    // unexpected data
                    continue
                }
                self.movieArray.append(newMovie)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func scrollToTop(_ sender: Any) {
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
    }
    
    // MARK: - PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsSegue" {
            let vc = segue.destination as! DetailsViewController
            vc.movie = movieArray[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        load(isNewSearch: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // check if lazy loading is needed
        if indexPath.row + 10 > movieArray.count{
            load(isNewSearch: false)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        cell.display(movie: movieArray[indexPath.row])
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
            load(isNewSearch: false)
        }
    }
    
}
