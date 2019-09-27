//
//  MovieBrowserDetailViewController.swift
//  MovieBrower
//
//  Created by sreejith on 26/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit
import SDWebImage

class MovieBrowserDetailViewController: UIViewController {

    @IBOutlet weak var movieScrollView: UIScrollView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieLanguage: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieVoteAverage: UILabel!
    @IBOutlet weak var movieSynopsis: UITextView!
    
    var movieBrowserDetails: Result?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    /// Call this function to setup the initial setup
    func initialSetup() {
        loadSelectedMovieDetails()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    ///Call this function to load selected Movie Details
    func loadSelectedMovieDetails() {
        movieTitle.text = movieBrowserDetails?.originalTitle ?? ""
        let posterImage = movieBrowserDetails?.posterPath ?? ""
        let imagePath = MovieBrowserAPI.imagePosterURL + posterImage
        let imageURL = URL(string: imagePath)
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
         let langugae = getLanguageStringUsingCode(langugaeCode: movieBrowserDetails?.originalLanguage ?? "")
        if langugae != "" {
            movieLanguage.text = langugae
        } else {
            movieLanguage.text = "Language not mentioned"
        }
         let releaseDate = movieBrowserDetails?.releaseDate ?? ""
         if releaseDate != "" {
            movieReleaseDate.text = Utilities.convertDateFormater(releaseDate) + " Release"
        } else {
            movieReleaseDate.text = "No release date yet"
        }
        movieVoteAverage.text = String(describing: movieBrowserDetails?.voteAverage ?? 0) + " User rating"
        movieSynopsis.text = movieBrowserDetails?.overview ?? ""
    }
    /// Call this function to get language string using language Code
    func getLanguageStringUsingCode(langugaeCode: String) -> String {
        let languageString = Locale.current.localizedString(forLanguageCode: langugaeCode)
        print("langugaeString",languageString!)
        return languageString ?? ""
    }
    
    //MARK:- Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
