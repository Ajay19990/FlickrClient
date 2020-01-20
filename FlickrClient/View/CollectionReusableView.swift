//
//  CollectionReusableView.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 20/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    
    let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
