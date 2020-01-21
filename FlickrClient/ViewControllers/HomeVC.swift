//
//  ViewController.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit

class HomeVC: UICollectionViewController{

    let cellId = "cellId"
    let loadingId = "loadingId"
    let paginationLoaderId = "paginationLoaderId"
    let label = HelperLabel()
    var activityIndicator2 = UIActivityIndicatorView()
    var photoViewModels = [PhotoViewModel]()
    var photos = [Photo]()
    var refreshButton: UIBarButtonItem!
    
    var page = 1
    var continuePagination = true
    var weHitBottom = false
    
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        configureRefreshButton()
        setupActivityIndicator()
        configureCollectionView()
    }
    
    private func configureRefreshButton() {
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    private func setupActivityIndicator() {
        activityIndicatorContainer = ActivityIndicatorContainer(view: view)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        view.addSubview(activityIndicatorContainer)
        
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: loadingId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPhotos(page: page)
    }
    
    private func getPhotos(page: Int) {
        loadingImages(true)
        FlickrClient.getPhotoData(page: page, completion: handlePhotoData)
    }
    
    private func handlePhotoData(photos: [Photo], error: ErrorMessage?) {
        if error != nil {
            DispatchQueue.main.async {
                self.loadingImages(false)
                self.presentAlert(title: error!.rawValue, message: "")
                self.setupLabel()
            }
        }
        
        if page == 3 { self.continuePagination = false }
        self.photos.append(contentsOf: photos)
        self.photoViewModels = self.photos.map({return PhotoViewModel(photo: $0)})
        label.removeFromSuperview()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.loadingImages(false)
        }
    }
    
    private func setupLabel() {
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func refreshTapped() {
        photoViewModels = []
        photos = []
        setupActivityIndicator()
        showActivityIndicator(show: true)
        getPhotos(page: 1)
        page = 1
        continuePagination = true
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
    
    // Pagination
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard continuePagination else { return }
            weHitBottom = true
            collectionView.reloadData()
            page += 1
            getPhotos(page: page)
        }
    }
    
}

    // MARK: - CollectionView Delegate Functions

extension HomeVC {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if weHitBottom {
            weHitBottom = false
            return 2
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return photoViewModels.count
        } else if section == 1 && continuePagination {
            return 1
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCell
            if indexPath.row < photoViewModels.count {
                cell.photoViewModel = photoViewModels[indexPath.row]
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingId, for: indexPath) as! LoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        detailVC.photoViewModel = photoViewModels[indexPath.row]
        present(detailVC, animated: true)
    }
}

    //MARK: - CollectionView FlowLayout

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: view.frame.width, height: 60)
        }
        let side = (view.frame.width - 2) / 3
        return CGSize(width: side, height: side)
    }
}
