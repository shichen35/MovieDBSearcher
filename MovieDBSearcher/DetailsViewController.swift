//
//  DetailsViewController.swift
//  MovieDBSearcher
//
//  Created by Chen Shi on 4/13/17.
//  Copyright © 2017 Chen Shi. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
  
  @IBOutlet weak var imgPoster: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblReleaseDate: UILabel!
  @IBOutlet weak var lblOverview: UILabel!
  @IBOutlet weak var lblRating: UILabel!
  @IBOutlet weak var lblGenre: UILabel!
  
  var movie: MovieObject?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let movie = movie {
      self.title = movie.title
      display()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func display() {
    if let movie = movie {
      let url = URL(string: "https://image.tmdb.org/t/p/original\(movie.posterUrl)")!
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
