//
//  LoadingCell.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 21/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    
    let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureActivityIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
