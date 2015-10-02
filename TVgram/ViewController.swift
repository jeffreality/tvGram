//
//  ViewController.swift
//  TVgram
//
//  Created by Jeffrey Berthiaume on 9/22/15.
//  Copyright © 2015 Jeffrey Berthiaume. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let downloader = InstagramDownloader()
    
    let spinner = UIActivityIndicatorView (activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    @IBOutlet weak var filterList: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var filterFocused = true
    var filterChanged = false
    
    override var preferredFocusedView:UIView? {
        if filterFocused {
            return filterList
        } else {
            return collectionView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        downloader.delegate = self
        downloader.downloadPhotos()
    }

    @IBAction func indexChanged(segmentedControl:UISegmentedControl) {
        spinner.startAnimating()
        collectionView.alpha = 0.4
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            downloader.orderedByLikes()
        case 1:
            downloader.orderedByComments()
        default:
            break;
        }
        filterChanged = true
    }
    
    @IBAction func filterClicked(sender: UISegmentedControl) {
        if filterChanged == false {
            filterFocused = false
        
            self.view.setNeedsFocusUpdate()
        } else {
            filterChanged = false
        }
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloader.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellThumbnail", forIndexPath: indexPath) as! ThumbnailCell
        // Configure the cell
        let images = downloader.data
        
        if let url = NSURL(string: images[indexPath.row]["image"]!) {
            if let data = NSData(contentsOfURL: url){
                cell.thumbnail.image = UIImage(data: data)
                switch filterList.selectedSegmentIndex {
                case 0:
                    cell.counter.text = NSNumberFormatter.localizedStringFromNumber(Int(images[indexPath.row]["likes"]!)!, numberStyle: NSNumberFormatterStyle.DecimalStyle)
                case 1:
                    cell.counter.text = NSNumberFormatter.localizedStringFromNumber(Int(images[indexPath.row]["comments"]!)!, numberStyle: NSNumberFormatterStyle.DecimalStyle)
                default:
                    cell.counter.text = ""
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // could pop up a larger view of the image
        // for now, goes back to the filter list menu
        
        filterFocused = true
        self.view.setNeedsFocusUpdate()
        
    }
    
}

extension ViewController: InstagramDownloaderDelegate {
    
    func didUpdatePhotos() {
        // refresh collectionView
        collectionView.alpha = 1.0
        spinner.stopAnimating()
        collectionView.reloadData()
    }
    
}

class ThumbnailCell: UICollectionViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var counter: UILabel!
}