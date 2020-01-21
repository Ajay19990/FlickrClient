//
//  SectionHeaderView.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 21/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    let countLabel = UILabel()
    var page: Int! {
        didSet {
            countLabel.text = "Page Number: \(page ?? 0)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGreen
        configureCountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCountLabel() {
        addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor),
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4)
        ])
        countLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        countLabel.textColor = .white
    }
    
}
