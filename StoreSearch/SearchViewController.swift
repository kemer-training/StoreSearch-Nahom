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
        static let loadingCell = "LoadingCell"
    }
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var hasSearched = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        
        registerCustomCells()
    }
    
    func registerCustomCells(){
        let cellNib = UINib(
            nibName: TableView.CellIdentifiers.searchResultCell,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell
        )
        
        let emptyNib = UINib(
            nibName: TableView.CellIdentifiers.nothingFoundCell,
            bundle: nil
        )
        tableView.register(
            emptyNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell
        )
        
        let loadingNib = UINib(
            nibName: TableView.CellIdentifiers.loadingCell,
            bundle: nil
        )
        tableView.register(
            loadingNib,
            forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell
        )
    }
    
    func iTunesURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = String(
            format:"https://itunes.apple.com/search?term=%@&limit=200",
            encodedText
        )
        let url = URL(string: urlString)
        
        return url!
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
            title: "OK",
            style: .default
        )
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
}


extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        hasSearched = true
        isLoading = true
        
        
        
        if !searchBar.text!.isEmpty{
            
            searchBar.resignFirstResponder()
            searchResults = []
 
//            let queue = DispatchQueue.global()
            let url = iTunesURL(searchText: searchBar.text!)
            let session = URLSession.shared


            let dataTask = session.dataTask(with: url) {data, response, error in
                if let error = error{
                    print("Failed - \(error.localizedDescription)")
                }
                else if let httpResponse = response as? HTTPURLResponse,
                            httpResponse.statusCode == 200 {
                    print("Success - \(data!)")
                    searchResults = self.parse(data: data!)
                    searchResults.sort(by: <)
                    
                    DispatchQueue.main.async {
                        self.hasSearched = false
                        self.isLoading = false
                        self.tableView.reloadData()
                        self.showNetworkError()
                    }
                }
                else if let httpResponse = response as? HTTPURLResponse,
                            httpResponse.statusCode == 404 {
                    print("Page Not Found")
                }
            }
            dataTask.resume()
//            queue.async {
//                if let data = self.performStoreRequest(with: url){
//                    searchResults = self.parse(data: data)
//                    searchResults.sort(by: <)
//
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//                        self.tableView.reloadData()
//                    }
//                    return
//                }
//            }
        }
        tableView.reloadData()
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || (hasSearched && searchResults.count == 0){
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: SearchResultCell
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableView.CellIdentifiers.loadingCell,
                for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
         
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        }
        else{
            let searchResult = searchResults[indexPath.row]
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
        if searchResults.isEmpty || isLoading {
            return nil
        }
    
        return indexPath
    }
    
    
    
}
