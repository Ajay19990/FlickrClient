//
//  HelperLabel.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 20/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class HelperLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        text = "No images to display"
        textColor = .label
        textAlignment = .center
        font = .systemFont(ofSize: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
