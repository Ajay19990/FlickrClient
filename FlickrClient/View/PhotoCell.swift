//
//  PhotoCell.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let placeholderImageName = "placeholder"
    
    var photoViewModel: PhotoViewModel? {
        
        didSet {
            guard let photoViewModel = photoViewModel else { return }
            guard let url = photoViewModel.url else {
                imageView.image = UIImage(named:  placeholderImageName)
                return
            }
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: placeholderImageName), options: [], context: nil)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
}
