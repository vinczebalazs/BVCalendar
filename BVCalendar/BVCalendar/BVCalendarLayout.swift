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

final class BVCalendarLayout: UICollectionViewFlowLayout {
    
    weak var delegate: BVCalendarLayoutDelegate!
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributesArray = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let attributesArray = superAttributesArray.map { $0.copy() } as! [UICollectionViewLayoutAttributes]
        var x: CGFloat = sectionInset.left
        var y: CGFloat = 0

        for attributes in attributesArray {
            if attributes.representedElementCategory != .cell { continue }
            
            if attributes.frame.origin.y >= y && attributes.indexPath.item > 0 {
                // Align to the left if in a new row which is not the first of a section.
                x = sectionInset.left
            }

            if attributes.indexPath.section == 0 && attributes.indexPath.item == 0 {
                // Offset the first cell because the first day of a month isn't always the first weekday.
                attributes.frame.origin.x = CGFloat(delegate.offsetForItem(at: attributes.indexPath)) * attributes.frame.width
                x += attributes.frame.maxX
            } else {
                // Place the cell after the previous one.
                attributes.frame.origin.x = x
                x += attributes.frame.width
            }

            y = attributes.frame.maxY
        }
        return attributesArray
    }
    
}
