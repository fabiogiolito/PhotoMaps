//
//  PhotoStripCollectionView.swift
//  PhotoMaps
//
//  Created by Fabio Giolito on 19/10/2018.
//  Copyright © 2018 Fabio Giolito. All rights reserved.
//

import UIKit

class PhotoStripCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // =========================================
    // MODEL
    
    var map: Map!
    
    // Control map from Collection View actions
    var mapTargetDelegate: CollectionViewMapTarget!
    
    // =========================================
    // INITIALIZERS
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        // Set delegates
        self.delegate = self
        self.dataSource = self
        
        // Background
        self.backgroundColor = .white
        
        // Hide scroll bars
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        // Register cells
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        cell.backgroundView = UIImageView(image: location.image)
        cell.backgroundView?.contentMode = .scaleAspectFill
        cell.clipsToBounds = true
        return cell
    }

    // Size images to full height
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    // Tapped image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Recenter map on pin
        mapTargetDelegate.recenterMap(index: indexPath.row)
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
            mapTargetDelegate.recenterMap(index: index.row)
        }
    }
}

// PROTOCOL
protocol CollectionViewMapTarget {
    func recenterMap(index: Int) -> Void
}
