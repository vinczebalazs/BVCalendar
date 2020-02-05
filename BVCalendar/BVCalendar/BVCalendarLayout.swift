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
    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let superAttributesArray = super.layoutAttributesForElements(in: rect) else { return nil }
//
//        let attributesArray = superAttributesArray.map { $0.copy() } as! [UICollectionViewLayoutAttributes]
//        var x: CGFloat = sectionInset.left
//        var y: CGFloat = 0
//
//        for attributes in attributesArray {
//            if attributes.representedElementCategory != .cell { continue }
//
//            if attributes.frame.origin.y >= y && attributes.indexPath.item > 0 {
//                // Align to the left if in a new row which is not the first of a section.
//                x = sectionInset.left
//            }
//
//            if attributes.indexPath.section == 0 && attributes.indexPath.item == 0 {
//                // Offset the first cell because the first day of a month isn't always the first weekday.
//                attributes.frame.origin.x = CGFloat(delegate.offsetForItem(at: attributes.indexPath)) * attributes.frame.width
//                x += attributes.frame.width + minimumInteritemSpacing
//            } else {
//                // Place the cell after the previous one.
//                attributes.frame.origin.x = x
//                x += attributes.frame.width + minimumInteritemSpacing
//            }
//
//            // Place the cell after the previous one.
//            attributes.frame.origin.x = x
//            x += attributes.frame.width + minimumInteritemSpacing
//
//            y = attributes.frame.maxY
//        }
//
//        return attributesArray
//    }
//
//
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard scrollDirection == .vertical else { return super.layoutAttributesForElements(in: rect) }

        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }

        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })

        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { $0.center.y } ) {
            // Set the initial left inset
            var leftInset = sectionInset.left

            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                if attribute.indexPath.item == 0 {
                    // Offset the first cell because the first day of a month isn't always the first weekday.
                    attribute.frame.origin.x = CGFloat(delegate.offsetForItem(at: attribute.indexPath)) * attribute.frame.width
                } else {
                    attribute.frame.origin.x = leftInset
                }
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
//
//        var x: CGFloat = sectionInset.left
//        var y: CGFloat = -1.0
//
//        for a in cellAttributes {
//            if a.frame.minY >= y {
////                print(a.frame.origin.y)
////                print(x)
//                x = sectionInset.left
//            }
//            a.frame.origin.x = x
//            print(x)
//            x = a.frame.maxX + minimumInteritemSpacing
//            y = a.frame.maxY
//        }

        return layoutAttributes
    }

}
