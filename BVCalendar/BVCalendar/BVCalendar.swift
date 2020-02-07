//
//  BVCalendar.swift
//  BVCalendar
//
//  Created by Balazs Vincze on 2020. 01. 27..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//

import UIKit

@IBDesignable
final class BVCalendar: UIView {
    
    // MARK: Property Overrides
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: frame.width, height: dayNameLabelsStackView.frame.height + (frame.width / 7) * 6 + 50)
    }
     
    // MARK: Public Properties

    var selectedDate: Date?
    var rangeStartDate: Date? {
        if let indexPath = rangeStartIndexPath {
            return date(at: indexPath)
        } else {
            return nil
        }
    }
    var rangeEndDate: Date? {
        if let indexPath = rangeEndIndexPath {
            return date(at: indexPath)
        } else {
            return nil
        }
    }
    var allowsPastDateSelection = false
    var allowsRangeSelection = false {
        didSet {
            collectionView.allowsMultipleSelection = allowsRangeSelection
        }
    }
    
    // MARK: Private Properties

    private lazy var collectionView: UICollectionView = {
        let layout = BVCalendarLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BVCalendarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.register(BVCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.allowsMultipleSelection = allowsRangeSelection
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private lazy var dayNameLabelsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        for i in 0..<7 {
            let label = UILabel()
            label.text = calendar.shortWeekdaySymbols[(i + calendar.firstWeekday - 1) % 7]
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
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
    private var didScroll = false
    private var rangeStartIndexPath: IndexPath?
    private var rangeEndIndexPath: IndexPath?
    
    // MARK: Function Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if !didScroll {
            didScroll = true
            let indexPath = self.indexPath(for: (selectedDate ?? rangeStartDate) ?? Date())
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            scrollTo(section: indexPath.section, animated: false)
        }
    }
    
    // MARK: Public Functions

    func setSelectedRange(from: Date, to: Date) {
        precondition(allowsRangeSelection, "Range selection must be enabled on the calendar.")
        rangeStartIndexPath = indexPath(for: from)
        rangeEndIndexPath = indexPath(for: to)
        collectionView.layoutIfNeeded()
        collectionView.reloadData()
    }
    
    // MARK: Private Functions
    
    private func setup() {
        addSubview(dayNameLabelsStackView)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            dayNameLabelsStackView.leftAnchor.constraint(equalTo: leftAnchor),
            dayNameLabelsStackView.topAnchor.constraint(equalTo: topAnchor),
            dayNameLabelsStackView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.topAnchor.constraint(equalTo: dayNameLabelsStackView.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func indexPath(for date: Date) -> IndexPath {
        let dateComponents = calendar.dateComponents([.month, .day], from: date)
        let section = calendar.dateComponents([.month], from: startDate, to: date).month!
        return IndexPath(item: dateComponents.day! - 1, section: section)
    }
    
    private func date(at indexPath: IndexPath) -> Date {
        var date = calendar.date(byAdding: .month, value: indexPath.section, to: startDate)!
        date = calendar.date(byAdding: .day, value: indexPath.row, to: date)!
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
    
    private func scrollTo(section: Int, animated: Bool = false) {
        // Scroll to the given section header (aka the month).
        layoutIfNeeded()
        if let frame = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader,
                                                                              at: IndexPath(item: 0, section: section))?.frame {
            collectionView.setContentOffset(frame.origin, animated: animated)
        }
    }
    
    private func reloadItemsInRange() {
        guard let start = rangeStartIndexPath, let end = rangeEndIndexPath else { return assertionFailure() }
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems.filter { $0 >= start && $0 <= end })
        }
        collectionView.selectItem(at: start, animated: false, scrollPosition: [])
        collectionView.selectItem(at: end, animated: false, scrollPosition: [])
    }

}

// MARK: UICollectionViewDataSource

extension BVCalendar: UICollectionViewDataSource {
    
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
        cell.isUserInteractionEnabled = allowsPastDateSelection || dateForCell >= Date()
        cell.containsCurrentDate = calendar.isDateInToday(dateForCell)
        guard let rangeStartDate = rangeStartDate, let rangeEndDate = rangeEndDate else { return cell }

        if allowsRangeSelection && cell.isUserInteractionEnabled {
            cell.isSelected = indexPath == rangeStartIndexPath || indexPath == rangeEndIndexPath
        }

        if rangeStartIndexPath == indexPath {
            cell.rangeIndicator = .start
        } else if dateForCell > rangeStartDate && dateForCell < rangeEndDate {
            if indexPath.row % 7 == 0 {
                cell.rangeIndicator.insert(.rowStart)
            } else if (indexPath.row + 1) % 7 == 0 {
                cell.rangeIndicator.insert(.rowEnd)
            } else {
                cell.rangeIndicator = .middle
            }
        } else if rangeEndIndexPath == indexPath {
            cell.rangeIndicator = .end
        } else {
            cell.rangeIndicator = .none
        }
                
        return cell
    }
    
}

// MARK: UICollectionViewDelegate

extension BVCalendar: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if allowsRangeSelection {
            if rangeStartIndexPath == nil {
                // Select start date.
                rangeStartIndexPath = indexPath
            } else if rangeEndIndexPath == nil && rangeStartIndexPath! < indexPath {
                // Select end date.
                rangeEndIndexPath = indexPath
                reloadItemsInRange()
            } else {
                // Select a new start date.
                rangeStartIndexPath = indexPath
                rangeEndIndexPath = nil
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        } else {
            selectedDate = date(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if allowsRangeSelection {
            rangeEndIndexPath = nil
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.selectItem(at: rangeStartIndexPath!, animated: false, scrollPosition: [])
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension BVCalendar: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 7, height: collectionView.frame.width / 7)
    }
    
}

// MARK: UIScrollViewDelegate

extension BVCalendar: UIScrollViewDelegate {

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

extension BVCalendar: BVCalendarLayoutDelegate {
    
    func offsetForItem(at indexPath: IndexPath) -> Int {
        calendar.dateComponents([.weekday], from: date(at: indexPath)).weekday! - calendar.firstWeekday
    }
    
}
