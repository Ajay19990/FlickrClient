//
//  ViewController.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"
    let label = UILabel()
    var activityIndicator2 = UIActivityIndicatorView()
    var photoViewModels = [PhotoViewModel]()
    var photos = [Photo]()
    var refreshButton: UIBarButtonItem!
    
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        //configureActivityIndicator()
        configureRefreshButton()
        setupActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        loadingImages(true)
        FlickrClient.getPhotoData(completion: handlePhotoData)
    }
    
    private func setupActivityIndicator() {
        
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = view.center.x
        activityIndicatorContainer.center.y = view.center.y
        activityIndicatorContainer.backgroundColor = .systemGray5
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
          
        // Configure the activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        view.addSubview(activityIndicatorContainer)
            
        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 90),
            activityIndicator.widthAnchor.constraint(equalToConstant: 90)
        ])
        
        activityIndicator.hidesWhenStopped = true
    }
    
    private func configureRefreshButton() {
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    private func handlePhotoData(photos: [Photo], error: ErrorMessage?) {
        self.photos = photos
        self.photoViewModels = self.photos.map({return PhotoViewModel(photo: $0)})
        if error != nil {
            DispatchQueue.main.async {
                self.loadingImages(false)
                self.presentAlert(title: error!.rawValue, message: "")
                self.setupLabel()
            }
        }
        label.removeFromSuperview()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.loadingImages(false)
        }
    }
    
    private func setupLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        label.text = "No images to display"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
    }

    @objc func refreshTapped() {
        loadingImages(true)
        photoViewModels = []
        setupActivityIndicator()
        showActivityIndicator(show: true)
        FlickrClient.getPhotoData(completion: handlePhotoData)
    }
    
    private func loadingImages(_ loadingImages: Bool) {
        if loadingImages {
            showActivityIndicator(show: true)
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = false
            refreshButton.isEnabled = false
        } else {
            showActivityIndicator(show: false)
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            refreshButton.isEnabled = true
        }
    }
    
    private func showActivityIndicator(show: Bool) {
      if show {
        DispatchQueue.main.async{
            self.activityIndicator.startAnimating()
            self.refreshButton.isEnabled = false
        }
      } else {
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.activityIndicatorContainer.removeFromSuperview()
            }
        }
    }
    
}

extension HomeVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCell
        if indexPath.row < photoViewModels.count {
            cell.photoViewModel = photoViewModels[indexPath.row]
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        detailVC.photoViewModel = photoViewModels[indexPath.row]
        present(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (view.frame.width - 2) / 3
        return CGSize(width: side, height: side)
    }
}

struct UrlBuilder {
    let index: Int
    let photos: [Photo]
    
    init(index: Int, photos: [Photo]) {
        self.index = index
        self.photos = photos
    }
}
