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
    let headerId = "headerId"
    let label = HelperLabel()
    var activityIndicator2 = UIActivityIndicatorView()
    var refreshButton: UIBarButtonItem!
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var photoViewModels = [PhotoViewModel]()
    var parentArray = [[PhotoViewModel]]()
    
    var page = 1
    var continuePagination = true
    
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
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
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
        self.photoViewModels = photos.map({return PhotoViewModel(photo: $0)})
        parentArray.append(self.photoViewModels)
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
        parentArray = []
        setupActivityIndicator()
        showActivityIndicator(show: true)
        page = 1
        getPhotos(page: page)
        continuePagination = true
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
            self.activityIndicator.startAnimating()
            self.refreshButton.isEnabled = false
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicatorContainer.removeFromSuperview()
        }
    }
    
    // Pagination
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard continuePagination else { return }
            page += 1
            setupActivityIndicator()
            showActivityIndicator(show: true)
            getPhotos(page: page)
        }
    }
    
}

    // MARK: - CollectionView Delegate Functions

extension HomeVC {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parentArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parentArray[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoViewModels = parentArray[indexPath.section]
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! SectionHeaderView
        sectionHeaderView.page = indexPath.section + 1
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
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
        let side = (view.frame.width - 2) / 3
        return CGSize(width: side, height: side)
    }
}
