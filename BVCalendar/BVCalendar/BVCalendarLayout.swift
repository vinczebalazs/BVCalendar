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
        var cellXOffset = CGFloat(0)
        
        for section in 0..<collectionView.numberOfSections {
                        
            // Calculate section header attributes.
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                              with: IndexPath(item: 0, section: section))
            attributes.frame = CGRect(x: 0, y: lastFrame.maxY, width: collectionView.bounds.width, height: sectionHeight)
            cachedHeaderAttributes.append(attributes)
            lastFrame = attributes.frame

            for item in 0..<collectionView.numberOfItems(inSection: section) {
                
                // Calculate cell attributes.
                var frame = CGRect(x: cellXOffset, y: item == 0 ? lastFrame.maxY : lastFrame.minY,
                                   width: collectionView.bounds.width / 7, height: collectionView.bounds.width / 7)
                
                if section == 0 && item == 0 {
                    // Offset the first cell because the first day of a month isn't always the first weekday.
                    let offset = delegate.offsetForItem(at: IndexPath(item: item, section: section))
                    frame.origin.x = CGFloat(offset) * frame.width
                    frame.origin.y = lastFrame.maxY
                }
                
                if frame.maxX > collectionView.bounds.width {
                    // Break onto a new line if the cell would go off-screen.
                    frame.origin.x = 0
                    frame.origin.y = lastFrame.maxY
                }
                                 
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                lastFrame = frame
                cellXOffset = frame.maxX
                cachedCellAttributes[indexPath] = attributes
                
                // Grow the content bounds so the collection view grows too.
                contentBounds = contentBounds.union(frame)
            }
        }
    }
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cachedHeaderAttributes + cachedCellAttributes.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedCellAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedHeaderAttributes[indexPath.section]
    }

}
