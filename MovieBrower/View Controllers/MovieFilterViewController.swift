//
//  MovieFilterViewController.swift
//  MovieBrower
//
//  Created by sreejith on 26/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit


protocol applySortOrderDelegate: class {
    func applySortOrder(orderValue: sortOrder, selectedIndexValue: Int)
}
class MovieFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sortTableView: UITableView!
    var selectedSortOrder: sortOrder!
    var selectedIndex: Int = 0
    var sorOrderList = [String]()
    weak var applySortDelegate: applySortOrderDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        sorOrderList = ["Most popular", "Highest rated"]
        sortTableView.delegate = self
        sortTableView.dataSource = self
        showSelectedOrder(indexPath: selectedIndex)
        // ensure that deselect is called on all other cells when a cell is selected
        // Do any additional setup after loading the view.
    }
    
    
    func showSelectedOrder(indexPath: Int) {
        selectedIndex = indexPath
        sortTableView.reloadData()
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.applySortDelegate?.applySortOrder(orderValue: selectedSortOrder, selectedIndexValue: selectedIndex)
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - UITabaleViewDelegate and UITabaleViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sorOrderList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "SortOrderCell", for: indexPath) as? SortOrderTableViewCell
        cell?.tickImage.isHidden = true
        if selectedIndex == indexPath.row {
            cell?.tickImage.isHidden = false
        } else{
            cell?.tickImage.isHidden = true
        }
        cell?.sortOrderTitle.text = sorOrderList[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case sortOrder.defaultSort.rawValue:
            self.selectedSortOrder = sortOrder.defaultSort
        case sortOrder.mostPopular.rawValue:
            self.selectedSortOrder = sortOrder.mostPopular
        case sortOrder.highestRating.rawValue:
            self.selectedSortOrder = sortOrder.highestRating
        default:
            break
        }
        showSelectedOrder(indexPath: indexPath.row)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
