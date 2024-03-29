//
//  ViewController.swift
//  MovieBrower
//
//  Created by sreejith on 24/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit



enum sortOrder: Int {
    case defaultSort = -1
    case mostPopular = 0
    case highestRating = 1
    
    public var sortString: String {
        switch self {
        case .mostPopular:
            return "popularity.desc"
        case .highestRating:
            return "vote_average.desc"
        case .defaultSort:
            return "popularity.desc"
        }
    }
}

class HomeMovieViewController: UIViewController {
    var movieBrowserList = MovieListModel()
    var searchBrowserList = MovieListModel()
    var searchActive : Bool = false
    var movieList: [Result]?
    var page = 1
    var isLoadingList = false
    var selectedSortOrder: sortOrder? = .defaultSort
    var selectedIndex: Int = 0
    var sortedBy: String = sortOrder.mostPopular.sortString
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noResultFound: UILabel!
    @IBOutlet weak var movieBrowserCollectionView: UICollectionView!
    @IBOutlet weak var searchMovieTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    func initialSetup() {
        noResultFound.text = "No Movie found"
        movieBrowserList.results = []
        searchBrowserList.results = []
        movieBrowserCollectionView.delegate = self
        movieBrowserCollectionView.dataSource = self
        searchMovieTextField.delegate = self
        searchMovieTextField.addTarget(self, action: #selector(textFieldDidChange(_:)),
                                       for: UIControl.Event.editingChanged)
        fetchMovieList(pageNumber: page, sortOrder: sortedBy)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// call this API to fetch Movie List
    func fetchMovieList(pageNumber: Int,sortOrder: String) {
        if Utilities.isConnectedToInternet {
            MovieBrowserAPI.getDiscoverMovie(pageNumber: pageNumber, sortOrder: sortOrder, completionHandler: { (response, errorResponse, errorMessage) in
                if errorMessage == nil && errorResponse == nil, let successResponse = response {
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
                    Utilities.toastMessage(errorResponse?.message ?? "Something went wrong")
                } else {
                    print("API Fail")
                    Utilities.toastMessage("Something went wrong")
                }
            })
        } else {
            Utilities.toastMessage("No internet connection")
        }
    }
    func getMovieListBySearch(searchText: String) {
        if Utilities.isConnectedToInternet {
            if searchText != "" {
                MovieBrowserAPI.getSearchMovie(query: searchText,pageNumber: page, completionHandler: { (response, errorResponse, errorMessage) in
                    if errorMessage == nil && errorResponse == nil, let successResponse = response {
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
                        self.searchActive = false
                        self.showHideNoDataWithMainDataLabel()
                        DispatchQueue.main.async {
                            self.movieBrowserCollectionView.reloadData()
                        }
                    } else {
                        print("API Fail")
                        self.searchActive = false
                        self.showHideNoDataWithMainDataLabel()
                        DispatchQueue.main.async {
                            self.movieBrowserCollectionView.reloadData()
                        }
                    }
                })
            } else {
                showLoadedData()
            }
        } else {
            Utilities.toastMessage("No internet connection")
        }
    }
    /// TextField Change and call the Api
    @objc func textFieldDidChange(_ textField: UITextField) {
        let searchedText = textField.text ?? ""
        getMovieListBySearch(searchText: searchedText)
    }
    
    private func showHideNoDataWithMainDataLabel() {
        if movieBrowserList.results?.count ?? 0 <= 0 {
            self.movieBrowserCollectionView.isHidden = true
            self.noResultFound.isHidden = false
        }
        else {
            self.movieBrowserCollectionView.isHidden = false
            self.noResultFound.isHidden = true
        }
    }
    private func showHideNoDataWithSearchDataLabel() {
        if searchBrowserList.results?.count ?? 0 <= 0 {
            self.movieBrowserCollectionView.isHidden = true
            self.noResultFound.isHidden = false
        }
        else {
            self.movieBrowserCollectionView.isHidden = false
            self.noResultFound.isHidden = true
        }
    }
    private func showLoadedData() {
        self.searchActive = false
        searchBrowserList = movieBrowserList
        DispatchQueue.main.async {
            self.movieBrowserCollectionView.reloadData()
        }
    }
    //MARK: - @IBAction
    /// This button action to sort the Movie List
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        if let movieFilter = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieFilterViewController") as? MovieFilterViewController {
            movieFilter.applySortDelegate = self
            movieFilter.selectedSortOrder = selectedSortOrder
            movieFilter.selectedIndex = selectedIndex
            navigationController?.pushViewController(movieFilter, animated: true)
        }
    }
}
//MARK: - UICollectionViewDelegate and UICollectionViewDataSource
extension HomeMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate  {
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
            self.navigationController?.pushViewController(movieDetailScreen, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchActive = false
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
                isLoadingList = true
                page += 1
                fetchMovieList(pageNumber: page, sortOrder: sortedBy)
            }
        }
    }
}

extension HomeMovieViewController: applySortOrderDelegate {
    func applySortOrder(orderValue: sortOrder, selectedIndexValue: Int) {
        selectedSortOrder = orderValue
        selectedIndex = selectedIndexValue
        if searchActive {
            searchBrowserList.results = []
        } else {
            movieBrowserList.results = []
        }
        switch orderValue {
        case .mostPopular:
            page = 1
            sortedBy = sortOrder.mostPopular.sortString
            print("most")
        case .highestRating:
            page = 1
            sortedBy = sortOrder.highestRating.sortString
            print("high")
        case .defaultSort:
            sortedBy = sortOrder.mostPopular.sortString
            print("default")
        }
        fetchMovieList(pageNumber: page, sortOrder: sortedBy)
    }
}
