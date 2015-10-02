//
//  InstagramDownloader.swift
//  TVgram
//
//  Created by Jeffrey Berthiaume on 9/23/15.
//  Copyright © 2015 Jeffrey Berthiaume. All rights reserved.
//

import Foundation

class InstagramDownloader: NSObject {
    
    var delegate:InstagramDownloaderDelegate! = nil
    var data:[[String: String]] = []
    
    func orderedBy(key:String) {
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            // sort on a background thread, so the spinner will animate
            self.data.sortInPlace {
                item1, item2 in
                let value1 = Double(item1[key]!)
                let value2 = Double(item2[key]!)
                return value1 > value2
            }
            
            // redraw the collection view on a foreground thread
            dispatch_async(dispatch_get_main_queue()) {
                // send message to reload data
                self.delegate!.didUpdatePhotos()
            }
            
        }
    }
    
    func orderedByComments () {
        orderedBy("comments")
    }
    
    func orderedByLikes () {
        orderedBy("likes")
    }
    
    func parseJSON(json: JSON) {
        for result in json["data"].arrayValue {
            let imageURL = result["images"]["standard_resolution"]["url"].stringValue
            let commentsCount = result["comments"]["count"].stringValue
            let likesCount = result["likes"]["count"].stringValue
            
            let obj = ["image": imageURL, "comments": commentsCount, "likes": likesCount]
            data.append(obj)
        }
        
        self.orderedByLikes()
    }
    
    func downloadPhotos () {
        
        let urlString = "https://api.instagram.com/v1/media/popular?client_id=" + "API_KEY_GOES_HERE"
        
        if let url = NSURL(string: urlString) {
            
            // background thread to download
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                if let instagramData = try? NSData(contentsOfURL: url, options: []) {
                    
                    // foreground thread, because updating UI
                    dispatch_async(dispatch_get_main_queue()) {
                        let json = JSON(data: instagramData)
                        
                        if json["meta"]["code"].intValue == 200 {
                            // main thread, because updating UI
                            self.parseJSON(json)
                        }
                    }
                }
                
            }
            
        }

        
    }
    
}

protocol InstagramDownloaderDelegate {
    func didUpdatePhotos ()
}