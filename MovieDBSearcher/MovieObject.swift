//
//  MovieObject.swift
//  MovieDBSearcher
//
//  Created by Chen Shi on 4/13/17.
//  Copyright © 2017 Chen Shi. All rights reserved.
//

import UIKit

class MovieObject {
    
    let posterUrl: String
    let title: String
    let overview: String
    let releaseDate: String
    let genre: [String]
    let score: Float
    static let genreMap: [Int:String] = [ 28: "Action", 12: "Adventure", 16: "Animation", 35: "Comedy", 80: "Crime", 99: "Documentary", 37: "Western", 10752: "War", 53: "Thriller", 10770: "TV Movie", 878: "Science Fiction", 10749: "Romance", 9648: "Mystery", 10402: "Music", 27: "Horror", 36: "History", 14: "Fantasy", 10751: "Family", 18: "Drama"]

    init(title: String, posterUrl: String, overview: String, releaseDate: String, genre: [String], score: Float) {
        self.title = title
        self.posterUrl = posterUrl
        self.overview = overview
        self.releaseDate = releaseDate
        self.genre = genre
        self.score = score
    }
    
    convenience init?(dict: Dictionary<String, Any>) {
        guard let title = dict["title"] as? String else {
                print("Missing title.")
                return nil
        }
        guard let overview = dict["overview"] as? String,
            let releaseDate = dict["release_date"] as? String,
            let genre = dict["genre_ids"] as? [Int],
            let score = dict["vote_average"] as? Float else {
                print("Missing information. \(dict)")
                return nil
        }
        var translatedGenre = [String]()
        for item in genre {
            if let genreStr = MovieObject.genreMap[item] {
                translatedGenre.append(genreStr)
            }
        }
        let posterUrl = dict["poster_path"] as? String ?? ""
        self.init(title: title, posterUrl: posterUrl, overview: overview, releaseDate: releaseDate, genre: translatedGenre, score: score)
    }
}
