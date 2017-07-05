//
//  SearchViewModel.swift
//  MovieDBSearcher
//
//  Created by Chen Shi on 7/5/17.
//  Copyright © 2017 Chen Shi. All rights reserved.
//

import UIKit

class SearchViewModel: NSObject {
    var movies: [MovieObject] = []
    var queryStr = ""
    var totalResults = 0
    var totalPages = 0
    var loadedPages = 0
    var isLoading = false
    
    func load(isNewSearch: Bool, url: String) {
        if isLoading {
            return
        }
        if isNewSearch {
            movies.removeAll()
//            tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
//            tableView.reloadData()
            loadedPages = 0
            totalPages = 0
            totalResults = 0
            queryStr = url
            if queryStr == "" {
                return
            }
        }else if loadedPages >= totalPages {
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
                self.movies.append(newMovie)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}


