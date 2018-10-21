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
        
        // Pagination
        // self.isPagingEnabled = true
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return map.locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let location = map.locations[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        cell.backgroundView = UIImageView(image: location.image)
        cell.backgroundView?.contentMode = .scaleAspectFill
        cell.clipsToBounds = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped image")
    }
    
    // make one fo the images always centered
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Find cell closest to the frame center with reference from the targetContentOffset.
        let frameCenter: CGPoint = self.center
        var targetOffsetToCenter: CGPoint = CGPoint(x: targetContentOffset.pointee.x + frameCenter.x, y: targetContentOffset.pointee.y + frameCenter.y)
        var indexPath: IndexPath? = self.indexPathForItem(at: targetOffsetToCenter)
        
        // Check for "edge case" where the target will land right between cells and then next neighbor to prevent scrolling to index {0,0}.
        while indexPath == nil {
            targetOffsetToCenter.x += 10
            indexPath = self.indexPathForItem(at: targetOffsetToCenter)
        }
        // safe unwrap to make sure we found a valid index path
        if let index = indexPath {
            // Find the centre of the target cell
            if let centerCellPoint: CGPoint = self.layoutAttributesForItem(at: index)?.center {
                
                // Calculate the desired scrollview offset with reference to desired target cell centre.
                let desiredOffset: CGPoint = CGPoint(x: centerCellPoint.x - frameCenter.x, y: centerCellPoint.y - frameCenter.y)
                targetContentOffset.pointee = desiredOffset
            }
            
            // Recenter map on pin
//            mapTargetDelegate.recenterMap(index: index.row)
        }
    
    }

}

// PROTOCOL
protocol CollectionViewMapTarget {
    func recenterMap(index: Int) -> Void
}
