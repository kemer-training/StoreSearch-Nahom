//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by NAHØM on 03/12/2022.
//

import UIKit

struct TableView{
    struct CellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var hasSearched = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        
        let cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        let emptyNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.register(emptyNib, forCellReuseIdentifier: "NothingFoundCell")


    }
}


extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        hasSearched = true
        if searchBar.text != "Ed Sheeran"{
            for i in 1...4 {
                let result = SearchResults()
                result.name = "Result \(i)"
                result.artistName = searchBar.text!
                searchResults.append(result)
            }
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasSearched && searchResults.count == 0{
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: SearchResultCell
       
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            cell.nameLabel.text = searchResults[indexPath.row].name
            cell.artistNameLabel.text = searchResults[indexPath.row].artistName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.isEmpty{
            return nil
        }
        return indexPath
    }
    
    
    
}
