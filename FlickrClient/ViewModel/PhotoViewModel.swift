//
//  PhotoViewModel.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 19/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit
import SDWebImage

struct PhotoViewModel {
    
    let url: URL?
    let title: String
    
    init(photo: Photo) {
        self.title = photo.title
        let urlString = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        
        if let url = URL(string: urlString) {
            self.url = url
        } else {
            self.url = nil
        }
    }
    
}
