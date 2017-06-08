//
//  ImagesCollectionViewController.swift
//  copycat
//
//  Created by Austin Tucker on 6/6/17.
//  Copyright © 2017 Austin Tucker. All rights reserved.
//

import UIKit

protocol FirebaseFetchDelegate: class {
    func getDataFromFirebase()
}

private let reuseIdentifier = "Cell"

class ImagesCollectionViewController: UIViewController, UICollectionViewDelegate {
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        firebaseImagesCollectionView = initializeCollectionView()
        firebaseImagesCollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        firebaseImagesCollectionView?.delegate = self
        firebaseImagesCollectionView?.dataSource = self
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        delegate = viewModel
        //self.addObserver(self, forKeyPath: "CacheModel.sharedInstance.storedImages", options: .new, context: nil)
        DispatchQueue.global().async {
            self.delegate?.getDataFromFirebase()
        }
    }
    
    weak var delegate: FirebaseFetchDelegate?
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "CacheModel.sharedInstance.storedImages" {
//            firebaseImagesCollectionView?.reloadData()
//        }
//    }
    
    var firebaseImagesCollectionView: UICollectionView?
    
    func initializeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 111, height: 111)
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        return collectionView
    }
    
    let previousImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func setupPreviousImageView(_ parent: UIView) {
        previousImageView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        previousImageView.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        previousImageView.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
        previousImageView.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
    }
    
//    deinit {
//        self.removeObserver(self, forKeyPath: "CacheModel.sharedInstance.storedImages")
//    }
}

//MARK UICollectionViewDataSource
extension ImagesCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.storedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        // Configure the cell
        self.setupPreviousImageView(cell.contentView)
        self.previousImageView.image = UIImage(data: viewModel.storedImages[indexPath.row])
        cell.contentView.addSubview(self.previousImageView)
        return cell
    }
}
