//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by NAHØM on 03/12/2022.
//

import UIKit

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
                searchResult.append(result)
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
        if hasSearched && searchResult.count == 0{
            return 1
        }
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        var cell = tableView.dequeueReusableCell(withIdentifier: "searchResult")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "searchResult")
        }
        
        if searchResult.count == 0{
            cell!.textLabel!.text = "(Nothing Found)"
            cell?.detailTextLabel?.text = ""
            
        }
        else{
            cell!.textLabel!.text = searchResult[indexPath.row].name
            cell?.detailTextLabel?.text = searchResult[indexPath.row].artistName
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResult.isEmpty{
            return nil
        }
        return indexPath
    }
    
    
    
}
