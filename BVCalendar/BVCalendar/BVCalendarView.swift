//
//  BVCalendarView.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 27..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

final class BVCalendarView: UIView {
    
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            (collectionView.collectionViewLayout as! BVCalendarLayout).delegate = self
            collectionView.register(BVCalendarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: headerIdentifier)
            collectionView.register(BVCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)

        }
    }
    @IBOutlet weak var dayNameLabelsStackView: UIStackView! {
        didSet {
            setDayNames()
        }
    }
    
    
//    override var intrinsicContentSize: CGSize {
//        CGSize(width: 100, height: 200)
//    }
    
    var selectedDate = Date()
    
    private let headerIdentifier = "CalendarHeader"
    private let cellIdentifier = "CalendarCell"
    private let today = Date()
    private lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return calendar
    }()
    private lazy var startDate: Date = {
        let currentYear = calendar.dateComponents([.year], from: today).year
        return calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
    }()
    
    override func awakeAfter(using coder: NSCoder) -> Any? {
        let view = loadFromNib()
        view?.frame = frame
        view?.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func set(selectedDate: Date) {
        self.selectedDate = selectedDate
        layoutIfNeeded()
        let dateComponents = calendar.dateComponents([.month, .day], from: selectedDate)
        let section = calendar.dateComponents([.month], from: startDate, to: selectedDate).month!
        // Select the corresponding cell for the date.
        collectionView.selectItem(at: IndexPath(item: dateComponents.day! - 1, section: section),
                                  animated: false, scrollPosition: [])
        scrollTo(section: section)
    }
        
    private func setDayNames() {
        for (i, subview) in dayNameLabelsStackView.arrangedSubviews.enumerated() {
            (subview as! UILabel).text = calendar.shortWeekdaySymbols[(i + calendar.firstWeekday - 1) % 7]
        }
    }
    
    private func date(at indexPath: IndexPath) -> Date {
        var date = calendar.date(byAdding: .month, value: indexPath.section, to: startDate)!
        date = calendar.date(byAdding: .day, value: indexPath.row + 1, to: date)!
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
    
    private func scrollTo(section: Int, animated: Bool = false) {
        // Scroll to the given section header (aka the month).
        if let headerFrame = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                    at: IndexPath(item: 0, section: section))?.frame {
            collectionView.setContentOffset(headerFrame.origin, animated: animated)
        }
    }

}

// MARK: UICollectionViewDataSource

extension BVCalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3 * 12 // Show months 3 years ahead.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        func isLeapYear() -> Bool {
            let year = calendar.component(.year, from: Date()) + section / 12
            return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)
        }
        
        switch (section + 1) % 12 {
        case 2:
            return isLeapYear() ? 29 : 28
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        default:
            return 30
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerIdentifier,
                                                                     for: indexPath) as! BVCalendarHeader
        header.date = calendar.date(byAdding: .month, value: indexPath.section, to: startDate)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! BVCalendarCell
        let dateForCell = date(at: indexPath)
        cell.label.text = "\(indexPath.row + 1)"
        cell.isUserInteractionEnabled = dateForCell >= Date()
        cell.containsCurrentDate = calendar.isDateInToday(dateForCell)
        return cell
    }
    
}

// MARK: UICollectionViewDelegate

extension BVCalendarView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = date(at: indexPath)
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension BVCalendarView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 7, height: collectionView.frame.width / 7)
    }
    
}

// MARK: UIScrollViewDelegate

extension BVCalendarView: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yOffset = collectionView.visibleSize.height / 2
        let leftPoint = CGPoint(x: collectionView.frame.width / 7, y: targetContentOffset.pointee.y + yOffset)
        let rightPoint = CGPoint(x: collectionView.frame.width, y: targetContentOffset.pointee.y + yOffset)
        var indexPath = collectionView.indexPathForItem(at: leftPoint) ?? collectionView.indexPathForItem(at: rightPoint)
        if indexPath == nil {
            // If no cell was found at the given index, it's because a section header is there, so use the index of the header.
            indexPath = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader).first
        }
        guard let section = indexPath?.section,
            let header = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                at: IndexPath(item: 0, section: section))
            else { return }
        // Adjust the target offset so the closest section's header is always at the top.
        targetContentOffset.pointee = header.frame.origin
    }
    
}

// MARK: BVCalendarLayoutDelegate

extension BVCalendarView: BVCalendarLayoutDelegate {
    
    func offsetForItem(at indexPath: IndexPath) -> Int {
        calendar.dateComponents([.weekday], from: date(at: indexPath)).weekday! - calendar.firstWeekday
    }
    
}
