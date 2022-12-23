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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?

    private let search = Search()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Search", comment: "Title of split view controller")
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            searchBar.becomeFirstResponder()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 91, left: 0, bottom: 0, right: 0)
        
        registerCustomCells()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass{
            case .compact:
                showLandscape(with: coordinator)
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            @unknown default:
                break
        }
    }
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        performSearch()
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
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC{
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChild(controller)
            
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil{
                    self.dismiss(animated: true)
                }
            }, completion: { _ in
                controller.didMove(toParent: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        guard let controller = landscapeVC else { return }
        
        controller.willMove(toParent: nil)
        coordinator.animate(alongsideTransition: { _ in
            if self.presentedViewController != nil {
              self.dismiss(animated: true, completion: nil)
            }
            controller.view.alpha = 0
            self.searchBar.becomeFirstResponder()
        }, completion: { _ in
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.landscapeVC = nil
        })

    }
    
    private func hidePrimaryPane(){
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.splitViewController?.preferredDisplayMode = .secondaryOnly
            },
            completion: {_ in
                self.splitViewController?.preferredDisplayMode = .automatic
            }
        )
    }
    
    
    
    func showNetworkError(){
        let alert = UIAlertController(
            title: NSLocalizedString("Oops...", comment: "Error alert: title"),
            message: NSLocalizedString("Couldn't access iTunes Store", comment: "Error alert: message"),
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: NSLocalizedString("OK", comment: "Alert button: title"),
            style: .default
        )
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}


extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex){
            search.performSearch(for: searchBar.text!, category: category){ success in
                if !success{
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeVC?.searchResultsReceived()
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
        switch search.state{
            case .notSearchedYet: return 0
            case .loading, .noResults: return 1
            case .results(let list): return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state{
            case .notSearchedYet:
                fatalError("Should never get here")
            case .loading:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: TableView.CellIdentifiers.loadingCell,
                    for: indexPath)
                
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
                
            case .noResults:
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
                
            case .results(let list):
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
                let searchResult = list[indexPath.row]
                cell.nameLabel.text = searchResult.name
                cell.configure(for: searchResult)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        
        if view.window?.rootViewController?.traitCollection.horizontalSizeClass == .compact{
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController?.preferredDisplayMode != .oneBesideSecondary{
                hidePrimaryPane()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state{
            case .notSearchedYet, .noResults, .loading: return nil
            case .results: return indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            if case .results(let list) = search.state{
                let detailVC = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                detailVC.searchResult = list[indexPath.row]
                detailVC.isPopUp = true
            }
        }
    }
    
}
