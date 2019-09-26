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
    let imagePosterURL :String = "https://image.tmdb.org/t/p/w500"

    override func awakeFromNib() {
        moviePoster.layer.cornerRadius = 8
        moviePoster.layer.masksToBounds = true
    }
    
    func setupCellData(movieResults: Result) {
        movieTitle.text = movieResults.originalTitle
        let posterImage =  movieResults.posterPath ?? ""
        let imagePath = imagePosterURL + posterImage
        let imageURL = URL(string: imagePath)
        moviePoster.sd_setShowActivityIndicatorView(true)
        moviePoster.sd_setIndicatorStyle(.white)
        print("imageURL", imageURL)
        if posterImage != "" {
        moviePoster?.sd_setImage(with: imageURL, placeholderImage: nil, completed: { (image, error, _, _) in
            if let photo = image {
                if error == nil, let _ = photo.pngData() {
                    //    UserDefaultsManager.profilePic = profilePic
                }
            }
        })
        } else {
            self.moviePoster.image = #imageLiteral(resourceName: "filterUnselected.png")
        }
    }
    
}
