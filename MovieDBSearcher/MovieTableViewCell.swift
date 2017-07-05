//
//  MovieTableViewCell.swift
//  MovieDBSearcher
//
//  Created by Chen Shi on 4/13/17.
//  Copyright © 2017 Chen Shi. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
  
  @IBOutlet weak var imgPoster: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblReleaseDate: UILabel!
  @IBOutlet weak var lblOverview: UILabel!
  @IBOutlet weak var lblRating: UILabel!
  @IBOutlet weak var lblGenre: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func display(movie : MovieObject) {
    let url = URL(string: "https://image.tmdb.org/t/p/w92\(movie.posterUrl)")!
    imgPoster.kf.setImage(with: url, placeholder: UIImage(named:"no-image.png"), options: nil, progressBlock: nil, completionHandler: nil)
    lblTitle.text = movie.title
    lblReleaseDate.text = movie.releaseDate
    lblOverview.text = movie.overview
    lblRating.text = String(format: "%.1f", movie.score)
    var genreStr = String()
    for genre in movie.genre {
      genreStr.append(genreStr.characters.count == 0 ? genre : ", \(genre)")
    }
    lblGenre.text = genreStr
  }
}
