//
//  PhotoStripCollectionView.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit
import TLPhotoPicker

class PhotoStripCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoCellDelegate {
    
    // =========================================
    // MODEL
    
    var map: Map! {
        didSet {
            showEmptyStateIfNoLocations()
            reloadData()
        }
    }

    enum CellIdentifier: String {
        case photoCell
    }

    
    // Control map from Collection View actions
    var photoStripDelegate: PhotoStripDelegate!
    
    // =========================================
    // SUBVIEWS
    
    lazy var emptyStateView: EmptyStateView = {
        let empty = EmptyStateView()
        empty.titleLabel.text = "No photos"
        empty.bodyLabel.text = "Tap Edit then add some photos to build your map"
        return empty
    }()


    // =========================================
    // INITIALIZERS
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        // Set delegates
        delegate = self
        dataSource = self
        
        // Background
        backgroundColor = .white
        clipsToBounds = false
        
        // Hide scroll bars
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        // Register cells
        register(PhotoStripCell.self, forCellWithReuseIdentifier: CellIdentifier.photoCell.rawValue)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // =========================================
    // FUNCTIONS
    
    // Empty state
    func showEmptyStateIfNoLocations() {
        if map.locations.count > 0 {
            self.backgroundView = nil
        } else {
            self.backgroundView = emptyStateView
        }
    }
    
    // Tapped delete button on photo cell
    func deletePhotoFromStrip(index: Int) {
        photoStripDelegate.deleteLocationFromMap(index: index)
    }
    
    
    // =========================================
    // COLLECTION VIEW FUNCTIONS
    
    // Numer of images
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return map.locations.count
    }
    
    // Build image cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let location = map.locations[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.photoCell.rawValue, for: indexPath) as! PhotoStripCell
        cell.imageView.image = location.image
        cell.delegate = self
        cell.deleteButton.isHidden = !self.photoStripDelegate.editingMode
        cell.deleteButton.tag = indexPath.row
        return cell
    }

    // Size images to full height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    // Tapped image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Recenter map on pin
        photoStripDelegate.focusOnLocationPin(index: indexPath.row)
        // Recenter collectionview on image
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // Make one of the images always centered on scroll end
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        // Find cell closest to the frame center with reference from the targetContentOffset.
        let frameCenter: CGPoint = self.center
        var targetOffsetToCenter: CGPoint = CGPoint(x: targetContentOffset.pointee.x + frameCenter.x, y: targetContentOffset.pointee.y + frameCenter.y)
        var indexPath: IndexPath? = self.indexPathForItem(at: targetOffsetToCenter)

        // Check for "edge case" where the target will land right between cells and then next neighbor
        // prevent scrolling to index {0,0}.
        while indexPath == nil {
            targetOffsetToCenter.x += 10
            indexPath = self.indexPathForItem(at: targetOffsetToCenter)
        }
        // safe unwrap to make sure we found a valid index path
        if let index = indexPath {
            // Find the center of the target cell
            if let centerCellPoint: CGPoint = self.layoutAttributesForItem(at: index)?.center {

                // Calculate the desired scrollview offset with reference to desired target cell center.
                let desiredOffset: CGPoint = CGPoint(x: centerCellPoint.x - frameCenter.x, y: centerCellPoint.y - frameCenter.y)
                targetContentOffset.pointee = desiredOffset
            }

            // Recenter map on image pin
            photoStripDelegate.focusOnLocationPin(index: index.row)
        }
    }
}

// PROTOCOL
protocol PhotoStripDelegate {
    var editingMode: Bool { get set }
    func focusOnLocationPin(index: Int) -> Void
    func deleteLocationFromMap(index: Int) -> Void
}
