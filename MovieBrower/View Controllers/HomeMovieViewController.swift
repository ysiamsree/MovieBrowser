//
//  ViewController.swift
//  MovieBrower
//
//  Created by sreejith on 24/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit
import SDWebImage

class HomeMovieViewController: UIViewController {
    var movieBrowserList = MovieListModel()
    var searchBrowserList = MovieListModel()
    var searchActive : Bool = false
    var movieList: [Result]?
    var page = 1
    var isLoadingList = false
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noResultFound: UILabel!
    @IBOutlet weak var movieBrowserCollectionView: UICollectionView!
    @IBOutlet weak var searchMovieTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieBrowserList.results = []
        searchBrowserList.results = []
        movieBrowserCollectionView.delegate = self
        movieBrowserCollectionView.dataSource = self
        searchMovieTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                       for: UIControl.Event.editingChanged)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
//        self.view.addGestureRecognizer(tapGesture)
        fetchMovieList(pageNumber: page)
        noResultFound.text = "No Movie found"
        // Do any additional setup after loading the view, typically from a nib.
    }
//    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
//        searchMovieTextField.resignFirstResponder()
//    }
    func showHideNoDataWithMainDataLabel() {
        if movieBrowserList.results?.count ?? 0 <= 0 {
            self.movieBrowserCollectionView.isHidden = true
            self.noResultFound.isHidden = false
        }
        else {
            self.movieBrowserCollectionView.isHidden = false
            self.noResultFound.isHidden = true
        }
    }
    
    func showHideNoDataWithSearchDataLabel() {
        if searchBrowserList.results?.count ?? 0 <= 0 {
            self.movieBrowserCollectionView.isHidden = true
            self.noResultFound.isHidden = false
        }
        else {
            self.movieBrowserCollectionView.isHidden = false
            self.noResultFound.isHidden = true
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        
    }
    func fetchMovieList(pageNumber: Int) {
        MovieBrowserAPI.getDiscoverMovie(pageNumber: pageNumber, completionHandler: { (response, errorResponse, errorMessage) in
            if errorMessage == nil && errorResponse == nil, let successResponse = response {
                print("Response Data", successResponse)
                let movieList = successResponse as? MovieListModel
                self.movieBrowserList.totalResults = movieList?.totalResults ?? 0
                self.movieBrowserList.totalPages = movieList?.totalPages ?? 0
                self.movieBrowserList.page = movieList?.page ?? 1
                
                if let movieResults = movieList?.results {
                    if movieResults.count > 0 {
                        self.movieBrowserList.results?.append(contentsOf: movieResults)
                        DispatchQueue.main.async {
                            self.movieBrowserCollectionView.reloadData()
                        }
                    } else {
                        self.showHideNoDataWithMainDataLabel()
                    }
                }
            } else if errorMessage == nil && response == nil, let _ = errorResponse as? ErrorResponse {
                print("API Fail")
            } else {
                print("API Fail")
            }
        })
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // filter tableViewData with textField.text
        let searchText  = textField.text ?? ""
        MovieBrowserAPI.getSearchMovie(query: searchText,pageNumber: page, completionHandler: { (response, errorResponse, errorMessage) in
            if errorMessage == nil && errorResponse == nil, let successResponse = response {
                print("Response Data", successResponse)
                let movieList = successResponse as? MovieListModel
                self.searchBrowserList.totalResults = movieList?.totalResults ?? 0
                self.searchBrowserList.totalPages = movieList?.totalPages ?? 0
                self.searchBrowserList.page = movieList?.page ?? 1
                if let movieResults = movieList?.results {
                    if movieResults.count > 0 {
                        
                        self.searchActive = true
                        self.searchBrowserList.results = movieResults
                        self.showHideNoDataWithSearchDataLabel()
                    } else {
                        self.searchBrowserList.results = movieResults
                        self.showHideNoDataWithSearchDataLabel()
                    }
                    DispatchQueue.main.async {
                        self.movieBrowserCollectionView.reloadData()
                    }
                }
            } else if errorMessage == nil && response == nil, let _ = errorResponse as? ErrorResponse {
                print("API Fail")
                // self.searchActive = false
                self.showHideNoDataWithMainDataLabel()
                DispatchQueue.main.async {
                    self.movieBrowserCollectionView.reloadData()
                }
            } else {
                print("API Fail")
                // self.searchActive = false
                self.showHideNoDataWithMainDataLabel()
                DispatchQueue.main.async {
                    self.movieBrowserCollectionView.reloadData()
                }
            }
        })
    }
}
extension HomeMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    //MARK: - Delegate and DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return searchBrowserList.results?.count ?? 0
        } else {
            return movieBrowserList.results?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as? MovieGridCollectionViewCell
        if searchActive {
            if let movieResults =  searchBrowserList.results?[indexPath.row] {
                movieCell?.setupCellData(movieResults: movieResults)
            }
        } else {
            if let movieResults =  movieBrowserList.results?[indexPath.row] {
                movieCell?.setupCellData(movieResults: movieResults)
            }
        }
        return movieCell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
                if let movieDetailScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieBrowserDetailViewController") as? MovieBrowserDetailViewController {
                    if searchActive {
                        if let movieResults =  searchBrowserList.results?[indexPath.row] {
                            movieDetailScreen.movieBrowserDetails = movieResults
                        }
                    } else {
                        if let movieResults =  movieBrowserList.results?[indexPath.row] {
                            movieDetailScreen.movieBrowserDetails = movieResults
                        }
                    }
                    self.navigationController?.pushViewController(movieDetailScreen, animated: false)
                }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.row)
//        if let movieDetailScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieBrowserDetailViewController") as? MovieBrowserDetailViewController {
//            if searchActive {
//                if let movieResults =  searchBrowserList.results?[indexPath.row] {
//                    movieDetailScreen.movieBrowserDetails = movieResults
//                }
//            } else {
//                if let movieResults =  movieBrowserList.results?[indexPath.row] {
//                    movieDetailScreen.movieBrowserDetails = movieResults
//                }
//            }
//            self.navigationController?.pushViewController(movieDetailScreen, animated: false)
//        }
//
//    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension HomeMovieViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isLoadingList = false
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        if scrollView == movieBrowserCollectionView {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if let pageCount = self.movieBrowserList.page, let arrayTotalCounts = self.movieBrowserList.totalPages, pageCount < arrayTotalCounts, !isLoadingList {
                //                    let pageSpinner = UIActivityIndicatorView(style: .gray)
                //                    pageSpinner.startAnimating()
                //                    pageSpinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: movieBrowserCollectionView.bounds.width, height: CGFloat(44))
                //                    self.movieBrowserCollectionView. = pageSpinner
                //                    self.movieBrowserCollectionView.tableFooterView?.isHidden = false
                isLoadingList = true
                page += 1
                fetchMovieList(pageNumber: page)
            }
        }
    }
}
