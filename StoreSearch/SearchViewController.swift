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
    
    func iTunesURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(
            format:"https://itunes.apple.com/search?term=%@",
            encodedText
        )
        let url = URL(string: urlString)
        
        return url!
    }
    
    func performStoreRequest(with url: URL) -> Data?{
        do{
            return try Data(contentsOf: url)
        }
        catch{
            print("Request error - \(error)")
        }
        showNetworkError()
        return nil
    }
    
    func parse(data: Data) -> [SearchResult]{
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
            
        } catch {
            print("JSON error - \(error)")
            return []
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(
            title: "Oops...",
            message: "Couldn't access iTunes Store",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Try Again",
            style: .default
        )
        let action2 = UIAlertAction(
            title: "Cancel",
            style: .default
        )
        
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true)
    }
    
    func sortSearchResults(){
        searchResults.sort(by: <)
    }
    
    
}


extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = true
        
        if !searchBar.text!.isEmpty{
            let url = iTunesURL(searchText: searchBar.text!)
            let data = performStoreRequest(with: url)
            
            if let data = data{
                print(parse(data: data))
                searchResults = parse(data: data)
                sortSearchResults()
                
            }
            else{
                searchResults = []
            }
            
        }
        else{
            searchResults = []
            hasSearched = false
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
        let searchResult = searchResults[indexPath.row]
        
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            
            cell.nameLabel.text = searchResult.name
            
            if searchResult.artist.isEmpty{
                cell.artistNameLabel.text = "Unknown"
            }
            else{
                cell.artistNameLabel.text = String(
                    format: "%@ (%@)",
                    searchResult.artist,
                    searchResult.type
                )
            }
            
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
