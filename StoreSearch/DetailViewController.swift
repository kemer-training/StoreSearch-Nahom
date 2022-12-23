//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by NAHØM on 11/12/2022.
//

import UIKit

class DetailViewController: UIViewController {
    
    enum AnimationStyle{
        case slide
        case fade
    }
    
    
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    
    var searchResult: SearchResult!{
        didSet{
            if isViewLoaded{
                updateUI()
            }
        }
    }
    
    
    var isPopUp = false
    
    private var downloadTask: URLSessionDownloadTask?
    
    private var dismissStyle = AnimationStyle.fade
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isPopUp{
            popupView.layer.cornerRadius = 10
            let gestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(close)
            )
            
            gestureRecognizer.cancelsTouchesInView = true
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            
            view.backgroundColor = .clear
            let dimmingView = GradientView(frame: CGRect.zero)
            dimmingView.frame = view.bounds
            view.insertSubview(dimmingView, at: 0)
        }
        else{
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
        }
        if searchResult != nil{
            updateUI()
        }
        
        
    }
    deinit {
        downloadTask?.cancel()
    }
    
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true)
    }
    
    @IBAction func openInStore(){
        if let url = URL(string: searchResult.storeURL){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func updateUI(){
        guard let result = searchResult,
              let largeUrl = URL(string: result.imageLarge)
        else { return }

        
        downloadTask = artworkImageView.loadImage(url: largeUrl)
        
        nameLabel.text = !result.name.isEmpty ? result.name : NSLocalizedString("Unknown", comment: "Localized Label: Unknown")
        artistNameLabel.text = !result.artist.isEmpty ? result.artistName : NSLocalizedString("Unknown", comment: "Localized Label: Unknown")
        
        kindLabel.text = result.type
        genreLabel.text = result.genre
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        var priceText = ""
        if result.price == 0{
            priceText = NSLocalizedString("Free", comment: "Localized Text: priceText")
        }
        else if let text = formatter.string(from: result.price as NSNumber){
            priceText = text
        }
        
        priceButton.setTitle(priceText, for: .normal)
        popupView.isHidden = false
    }
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
        
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle{
            case .slide:
                return SlideOutAnimationController()
            case .fade:
                return FadeOutAnimationController()
        }
    }
}
