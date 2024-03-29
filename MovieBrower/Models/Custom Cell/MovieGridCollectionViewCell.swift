//
//  MovieGridCollectionViewCell.swift
//  MovieBrower
//
//  Created by sreejith on 24/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit

class MovieGridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!

    override func awakeFromNib() {
        moviePoster.layer.cornerRadius = 8
        moviePoster.layer.masksToBounds = true
    }
    
    func setupCellData(movieResults: Result) {
        movieTitle.text = movieResults.originalTitle
        let posterImage =  movieResults.posterPath ?? ""
        let imagePath =  MovieBrowserAPI.imagePosterURL + posterImage
        let imageURL = URL(string: imagePath)
        moviePoster.sd_setShowActivityIndicatorView(true)
        moviePoster.sd_setIndicatorStyle(.white)
        if posterImage != "" {
        moviePoster?.sd_setImage(with: imageURL, placeholderImage: nil, completed: { (image, error, _, _) in
            if let photo = image {
                if error == nil, let _ = photo.pngData() {
                }
            }
        })
        } else {
            self.moviePoster.image = UIImage(named: "noposter.png")
        }
    }
    
}
