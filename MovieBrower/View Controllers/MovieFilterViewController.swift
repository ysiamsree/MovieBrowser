//
//  MovieFilterViewController.swift
//  MovieBrower
//
//  Created by sreejith on 26/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit


protocol applySortOrderDelegate: class {
    func applySortOrder(orderValue: sortOrder)
}
class MovieFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sortTableView: UITableView!
    var selectedSortOrder: sortOrder!
    var selectedIndex: Int = -1
    var sorOrderList = [String]()
    weak var applySortDelegate: applySortOrderDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        sorOrderList = ["Most popular", "Highest rated"]
        sortTableView.delegate = self
        sortTableView.dataSource = self
        // ensure that deselect is called on all other cells when a cell is selected
        sortTableView.allowsMultipleSelection = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.applySortDelegate?.applySortOrder(orderValue: selectedSortOrder)
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sorOrderList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "SortOrderCell", for: indexPath) as? SortOrderTableViewCell
        if selectedIndex == indexPath.row {
            cell?.accessoryType = .checkmark
        } else{
            cell?.accessoryType = .none
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
        selectedIndex = indexPath.row
        sortTableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        switch indexPath.row {
//        case sortOrder.defaultSort.rawValue:
//            self.selectedSortOrder = sortOrder.defaultSort
//        case sortOrder.mostPopular.rawValue:
//            self.selectedSortOrder = sortOrder.mostPopular
//        case sortOrder.highestRating.rawValue:
//            self.selectedSortOrder = sortOrder.highestRating
//        default:
//            break
//        }
        sortTableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
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
