//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by NAHØM on 11/12/2022.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult: SearchResult!
    
    var artWork: UIImageView?
    
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(close)
        )
        
        gestureRecognizer.cancelsTouchesInView = true
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil{
            showDataInPopup()
        }
    }
    deinit {
        downloadTask?.cancel()
    }
    
    @IBAction func close() {
//        downloadTask?.cancel()
        dismiss(animated: true)
    }
    
    @IBAction func openInStore(){
        if let url = URL(string: searchResult.storeURL){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showDataInPopup(){
        guard let result = searchResult,
              let largeUrl = URL(string: result.imageLarge)
        else { return }

        
        downloadTask = artworkImageView.loadImage(url: largeUrl)
        
        nameLabel.text = !result.name.isEmpty ? result.name : "Unknown"
        artistNameLabel.text = !result.artist.isEmpty ? result.artistName : "Unknown"
        
        kindLabel.text = result.type
        genreLabel.text = result.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        var priceText = ""
        if result.price == 0{
            priceText = "Free"
        }
        else if let text = formatter.string(from: result.price as NSNumber){
            priceText = text
        }
        
        priceButton.setTitle(priceText, for: .normal)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}
