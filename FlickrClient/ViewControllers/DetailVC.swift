//
//  DetailVC.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 19/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    var photoViewModel: PhotoViewModel!
    let imageView = UIImageView()
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureImageView()
    }
    
    private func configureNavBar() {
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        self.view.addSubview(navbar)

        let navItem = UINavigationItem(title: photoViewModel.title)
        let navBarbutton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(dismissView))
        navItem.rightBarButtonItem = navBarbutton

        navbar.items = [navItem]
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureImageView() {
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        FlickrClient.getImage(urlString: photoViewModel.url?.absoluteString ?? "") { (image, isImageFromCache) in
            self.imageView.image = image
        }
    }
    
}
