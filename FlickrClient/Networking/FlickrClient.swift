//
//  FlickrClient.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 19/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class FlickrClient {
    
    static let placeholderImage = UIImage(named: "placeholder")
    
    class func getPhotoData(page: Int, completion: @escaping ([Photo], ErrorMessage?) -> Void) {
        
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=\(page)&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s"
        
        guard let url = URL(string: urlString) else { return }
        AF.request(url).responseData { (response) in
            
            guard response.error == nil else {
                completion([], .unableToComplete)
                return
            }
            
            guard let responseData = response.data else {
                completion([], .invalidData)
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(FlickrRecentResponse.self, from: responseData)
                completion(jsonResponse.photos.photo, nil)
            } catch {
                completion([], .invalidResponse)
            }
            
        }
    }
    
    class func getImage(urlString: String, completion: @escaping (UIImage?, Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, false)
            return
        }
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            completion(imageFromCache, true)
        } else {
            
            AF.request(url).responseData { (response) in
                    
                guard response.error == nil else {
                    completion(nil, false)
                    return
                }
                    
                guard let responseData = response.data else {
                    completion(nil, false)
                    return
                }
                    
                let imageToCache = UIImage(data: responseData)
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
                completion(imageToCache, false)
            }
            
        }
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()
