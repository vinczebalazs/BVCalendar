//
//  CalendarLayout.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 28..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

protocol BVCalendarLayoutDelegate: AnyObject {
    func offsetForItem(at indexPath: IndexPath) -> Int
}

final class BVCalendarLayout: UICollectionViewLayout {
    
    weak var delegate: BVCalendarLayoutDelegate!
    
    private let sectionHeight = CGFloat(50)
    private var cachedHeaderAttributes = [UICollectionViewLayoutAttributes]()
    private var cachedCellAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentBounds = CGRect()
    
    override var collectionViewContentSize: CGSize {
        contentBounds.size
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        // Reset cached information.
        cachedHeaderAttributes.removeAll()
        cachedCellAttributes.removeAll()
        contentBounds = CGRect()
        
        var lastFrame = CGRect()
        var newRowBreakPoint = 0
        var yOffset = CGFloat(0)
        
        for section in 0..<collectionView.numberOfSections {
            
            // Calculate section header attributes.
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                              with: IndexPath(item: 0, section: section))
            attributes.frame = CGRect(x: 0, y: yOffset, width: contentBounds.width, height: sectionHeight)
            yOffset += attributes.frame.maxY
            cachedHeaderAttributes.append(attributes)
            
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                                
                // Calculate cell attributes.
                var frame = CGRect(x: lastFrame.maxX, y: yOffset,
                                   width: collectionView.frame.width / 7, height: collectionView.frame.width / 7)
                
                if newRowBreakPoint % 7 == 0 {
                    newRowBreakPoint = 0
                    yOffset += frame.height
                    frame.origin.x = 0
                    frame.origin.y = yOffset
                }
                
                newRowBreakPoint += 1
                
                if section == 0 && item == 0 {
                    // Offset the first cell because the first day of a month isn't always the first weekday.
                    let offset = delegate.offsetForItem(at: IndexPath(item: item, section: section))
                    frame.origin.x = CGFloat(offset) * frame.width
                    newRowBreakPoint += offset
                }
                
                lastFrame = frame
                
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cachedCellAttributes[indexPath] = attributes
                
                contentBounds = contentBounds.union(frame)
            }
        }
    }
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Loop through the cache and look for items that are within the given rect.
        cachedHeaderAttributes + cachedCellAttributes.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedCellAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print(cachedHeaderAttributes[indexPath.section].frame)
        return cachedHeaderAttributes[indexPath.section]
    }

}
