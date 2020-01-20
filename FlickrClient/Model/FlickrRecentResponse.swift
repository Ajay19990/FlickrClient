//
//  FlickrRecentResponse.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import Foundation

struct FlickrRecentResponse : Codable {
    let photos: Photos
    let stat: String
}
