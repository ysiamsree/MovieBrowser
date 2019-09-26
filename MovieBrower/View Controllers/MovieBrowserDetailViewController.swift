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

    let imagePosterURL :String = "https://image.tmdb.org/t/p/w500"

    @IBOutlet weak var movieScrollView: UIScrollView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieLanguage: UILabel!
    @IBOutlet weak var movieType: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieVoteAverage: UILabel!
    @IBOutlet weak var movieSynopsis: UITextView!
    
    var movieBrowserDetails: Result?
    override func viewDidLoad() {
        super.viewDidLoad()

        movieTitle.text = movieBrowserDetails?.originalTitle ?? ""
        let posterImage = movieBrowserDetails?.posterPath ?? ""
        let imagePath = imagePosterURL + posterImage
        let imageURL = URL(string: imagePath)
        moviePoster?.sd_setImage(with: imageURL, placeholderImage: nil, completed: { (image, error, _, _) in
            if let photo = image {
                if error == nil, let _ = photo.pngData() {
                    //    UserDefaultsManager.profilePic = profilePic
                }
            }
        })
        movieLanguage.text = movieBrowserDetails?.originalLanguage ?? ""
        movieType.text = "2D | U/A"
        movieReleaseDate.text = movieBrowserDetails?.releaseDate
        movieVoteAverage.text = String(describing: movieBrowserDetails?.voteAverage ?? 0) + " User rating"
        movieSynopsis.text = movieBrowserDetails?.overview ?? ""
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
