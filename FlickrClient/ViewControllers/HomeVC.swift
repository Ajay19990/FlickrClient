//
//  ViewController.swift
//  FlickrClient
//
//  Created by Ajay Choudhary on 18/01/20.
//  Copyright © 2020 Ajay Choudhary. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UICollectionViewController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let cellId = "cellId"
    let headerId = "headerId"
    var activityIndicator2 = UIActivityIndicatorView()
    var refreshButton: UIBarButtonItem!
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var photoViewModels = [PhotoViewModel]()
    var parentArray = [[PhotoViewModel]]()
    var pages = [Page]()
    var arrayOfPhotoEntities = [[PhotoEntity]]()
    var imageArrayHasData = true
    let reachable = "Network Connection Reachable"
    
    var pageNumber = 1
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
        setupFetchRequest()
        addObserver()
        downloadPhotos(page: pageNumber)
    }
    
    private func setupFetchRequest() {
        let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) { self.pages = result }
        for page in pages {
            let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
            let predicate = NSPredicate(format: "page == %@", page)
            fetchRequest.sortDescriptors = []
            fetchRequest.predicate = predicate
            if let images = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
                self.arrayOfPhotoEntities.append(images)
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NetworkReachabilityChanged"), object: nil, queue: nil, using: {
            (notification) in
            if let userInfo = notification.userInfo {
                if let reachableOrNot = userInfo["reachableOrNot"] as? String {
                    if reachableOrNot == self.reachable {
                        self.refresh()
                    }
                }
            }
        })
    }
    
    private func downloadPhotos(page: Int) {
        loadingImages(true)
        FlickrClient.getPhotoData(page: page, completion: handlePhotoData)
    }
    
    private func handlePhotoData(photos: [Photo], error: ErrorMessage?) {
        if error != nil {
            DispatchQueue.main.async {
                self.loadingImages(false)
                self.presentAlert(title: error!.rawValue, message: "")
            }
        }
        
        if pageNumber == 3 { self.continuePagination = false }
        if photos.count == 0 { imageArrayHasData = false }
        else { imageArrayHasData = true }
        self.photoViewModels = photos.map({return PhotoViewModel(photo: $0)})
        parentArray.append(self.photoViewModels)
        
        if pageNumber == 1 && imageArrayHasData {
            for page in pages {
                appDelegate.persistentContainer.viewContext.delete(page)
                try? appDelegate.persistentContainer.viewContext.save()
            }
            pages = []
        }
        
        if imageArrayHasData {
            let page = Page(context: appDelegate.persistentContainer.viewContext)
            page.pageNumber = Int64(pageNumber)
            try? appDelegate.persistentContainer.viewContext.save()
            pages.append(page)
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.loadingImages(false)
        }
    }

    @objc func refreshTapped() {
        refresh()
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
    
    private func refresh() {
        photoViewModels = []
        parentArray = []
        setupActivityIndicator()
        showActivityIndicator(show: true)
        pageNumber = 1
        downloadPhotos(page: self.pageNumber)
        continuePagination = true
    }
    
    // Pagination
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard continuePagination else { return }
            pageNumber += 1
            setupActivityIndicator()
            showActivityIndicator(show: true)
            downloadPhotos(page: pageNumber)
        }
    }
    
}

    // MARK: - CollectionView Delegate Functions

extension HomeVC {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if imageArrayHasData { return parentArray.count }
        else { return pages.count }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArrayHasData { return parentArray[section].count }
        else {
            let page = pages[section]
            let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
            let predicate = NSPredicate(format: "page == %@", page)
            fetchRequest.sortDescriptors = []
            fetchRequest.predicate = predicate
            if let images = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
                return images.count
            } else { return 0 }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCell
        cell.imageView.image = UIImage(named: "placeholder")
        guard imageArrayHasData == false else {
            if indexPath.section < parentArray.count {
                let photoViewModels = parentArray[indexPath.section]
                
                if indexPath.row < photoViewModels.count {
                    let photoViewModel = photoViewModels[indexPath.row]
                    FlickrClient.getImage(urlString: photoViewModel.url?.absoluteString ?? "") { (image, isImageFromCache) in
                        if isImageFromCache == false {
                            let page = self.pages[indexPath.section]
                            let photoEntity = PhotoEntity(context: self.appDelegate.persistentContainer.viewContext)
                            photoEntity.image = image?.pngData()
                            photoEntity.urlString = photoViewModel.url?.absoluteString
                            photoEntity.page = page
                            try? self.appDelegate.persistentContainer.viewContext.save()
                        }
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }
                    }
                }
            }
            return cell
        }
        
        let images = arrayOfPhotoEntities[indexPath.section]
        if indexPath.row < images.count {
            let image = images[indexPath.row]
            cell.imageView.image = UIImage(data: image.image!)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard imageArrayHasData else { return }
        let detailVC = DetailVC()
        let photoViewModels = parentArray[indexPath.section]
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
